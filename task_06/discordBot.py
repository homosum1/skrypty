import os
import discord
from dotenv import load_dotenv

from chatbot import Overlord, parse_user_prompt, promptToAction


load_dotenv()
TOKEN = os.getenv("DISCORD_TOKEN")


intents = discord.Intents.default()
intents.message_content = True
client = discord.Client(intents=intents)

@client.event
async def on_ready():
    print(f"Logged as: {client.user}")

@client.event
async def on_message(message):
    if message.author == client.user:
        return

    user_input = message.content.strip()

    if user_input.lower().startswith("!bot"):
        prompt = user_input[len("!bot"):].strip()

        overlord = Overlord()
        parsed = parse_user_prompt(prompt)
        response = promptToAction(parsed, overlord)

        await message.channel.send(f"{response}")

if __name__ == "__main__":
    client.run(TOKEN)