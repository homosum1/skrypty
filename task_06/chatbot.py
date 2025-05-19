import requests
import json
import os

DATA_STORAGE = "tournaments.json"

def olama_query(prompt: str) -> str:
    res = requests.post(
        "http://localhost:11434/api/generate",
        json={
            "model": "llama3",
            "prompt": prompt,
            "stream": False
        }
    )

    data = res.json()
    return data["response"]


class Player:
    def __init__(self, name: str, player_id: int):
        self.name = name
        self.player_id = player_id

    def convert_to_dict(self):
        return {"name": self.name, "id": self.player_id}

class Tournament:
    def __init__(self, name: str, start_date: str, prize: float):
        self.name = name
        self.start_date = start_date
        self.prize = prize
        self.players = [] 

    def add_player(self, player_name: str) -> Player:
        new_id = len(self.players) + 1
        player = Player(player_name, new_id)
        self.players.append(player)
        return player

    def convert_to_dict(self):
        return {
            "name": self.name,
            "start_date": self.start_date,
            "prize": self.prize,
            "players": [player.convert_to_dict() for player in self.players]
        }

def parse_user_prompt(prompt: str) -> dict:
    predefined_query = (
        "Jesteś asystentem e-sportowym. Twoim zadaniem jest analizowanie poleceń zadawanych przez uzytkownika"
        "i zamiana ich na komendy w formacie JSON. Kazde polecenie zadawane przez uzytkownika powinno pasować do jednej z akcji. Obsługiwane akcje:"
        "- akcja: list_tournaments jeśli uzytkownik poprosi o wylistowanie turniejow - bez dokladnych szczegolow"
        "- akcja: add_player (zawiera parametry: tournament, player) daj to jesli uzytkownik poprosi o dodanie gracza do turnieju i poda nazwe turnieju oraz nazwe gracza"
        "- akcja: show_tournament (zawiera parametry: tournament) daj to jesli uzytkownik poprosi o informacje o kontretnym turnieju i poda jego nazwe"
        "- akcja: show_instructions (nie zawiera parametrów)"
        "- akcja: print_all (nie zawiera parametrów) jeśli uzytkownik poprosi o wylistowanie turniejow - z dokladnymi szczegolami"
        "Zwracaj tylko czysty JSON bez komentarzy ani wyjaśnień. Parametry zawsze mają być wewnątrz pola 'data'. Nazwa akcji powinna odpowiadać polu: 'action' Jeśli polecenie od uzytkownika nie pasuje do zadnej akcji to dopasuj je domyslnie do akcji: show_instructions"
        "Polecenie uzytkownika: "
    )

    final_query = predefined_query + prompt
    result = olama_query(final_query)

    try:
        print(result)
        return json.loads(result.strip())
    except json.JSONDecodeError:
        return { "action": "print_error" }

def printAvaiableOptions():
    return (
        "Dostępne akcje:\n"
        "- list_tournaments\n"
        "- add_player (zawiera parametry: tournament, player)\n"
        "- show_tournament (zawiera parametry: tournament)\n"
        "- show_instructions\n"
        "- print_all\n"
    )

class Overlord:
    def __init__(self):
        self.tournaments = []
        self.loadData()

    def loadData(self):
        if not os.path.exists(DATA_STORAGE):
            self.saveData()
        
        with open(DATA_STORAGE, "r") as file:
            try:
                data = json.load(file)

                for t in data:
                    tournament = Tournament(t["name"], t["start_date"], t["prize"])
                    for p in t.get("players", []):
                        tournament.players.append(Player(p["name"], p["id"]))
                    self.tournaments.append(tournament)
            except:
                self.tournaments = []

    def saveData(self):
        with open(DATA_STORAGE, "w") as f:
            json.dump([tournament.convert_to_dict() for tournament in self.tournaments], f, indent=2)

    def find_tournament(self, name: str):
        for t in self.tournaments:
            if (t.name.lower() == name.lower() ):
                return t
        return None

    def create_tournament(self, name: str, start_date: str, prize: float):
        self.tournaments.append(Tournament(name, start_date, prize))
        self.save()

    def list_tournaments(self):
        return self.tournaments


def promptToAction(result: dict, overlord: Overlord) -> str:
    if "data" in result and "action" in result["data"]:
        result = result["data"]

    output = ""
    action = result.get("action")
    data = result.get("data", {})

    print(f"raw dict: {result}")
    print(f"captured data: {data} \ncaptured action: {action}\n\n")

    if action == "list_tournaments":
        tournaments = overlord.list_tournaments()
        if not tournaments:
            return "Aktualnie nie ma zadnych nadchodzacych turniejow"
        for t in tournaments:
            output += f"- {t.name} | start: {t.start_date} | nagroda: {t.prize} | zawodnicy: {len(t.players)}\n"
        return output.strip()

    elif action == "add_player":
        tournament_name = data.get("tournament")
        player_name = data.get("player")

        if not tournament_name:
            return "Brakuje nazwy turnieju."
        
        if not player_name:
            return "Brakuje nazwy gracza."

        tournament = overlord.find_tournament(tournament_name)

        if not tournament:
            return f"Nie znaleziono turnieju: {tournament_name}"

        player = tournament.add_player(player_name)
        overlord.saveData()

        return f"Gracz: {player.name} z numerem id: {player.player_id} został dodany do turnieju {tournament.name}"

    elif action == "show_tournament":
        tournament_name = data.get("tournament")
        tournament = overlord.find_tournament(tournament_name)
        
        if not tournament:
            return f"Nie znaleziono turnieju: {tournament_name}"

        output += f"🏆 Turniej: {tournament.name}\n"
        output += f"- Start: {tournament.start_date}\n"
        output += f"- Nagroda: {tournament.prize}\n"
        output += "- Zawodnicy:\n"

        for player in tournament.players:
            output += f"  - id: {player.player_id} name: {player.name}\n"
        return output.strip()

    elif action == "print_all":
        tournaments = overlord.list_tournaments()
        if not tournaments:
            return "Brak zapisanych turniejów."

        for t in tournaments:
            output += f"🏆 Turniej: {t.name}\n"
            output += f"- Start: {t.start_date}\n"
            output += f"- Nagroda: {t.prize}\n"
            output += "- Zawodnicy:\n"
            if not t.players:
                output += "  (Brak zawodników)\n"
            else:
                for p in t.players:
                    output += f"  - id: {p.player_id}, name: {p.name}\n"
            output += "\n"
        return output.strip()

    else:
        return printAvaiableOptions()
