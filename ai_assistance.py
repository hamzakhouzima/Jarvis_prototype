import sys
import os
from openai import OpenAI

def generate_code(prompt):
    client = OpenAI(
        # api_key=os.environ.get("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")
       api_key = "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"
    )
    
    response = client.chat.completions.create(
        messages=[
            {
                "role": "user",
                "content": prompt,
            }
        ],
        model="gpt-3.5-turbo",
    )
    
    return response.choices[0].message['content'].strip()

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python ai_assistant.py <prompt>")
        sys.exit(1)
        
    prompt = sys.argv[1]
    result = generate_code(prompt)
    print(result)

