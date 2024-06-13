import sys
import os
import openai  
def generate_code(prompt):
    openai.api_key = "sk-filahati-vKfpTeKHVqcp7AuTmgKvT3BlbkFJuRyitFCyN1glGEmj2U1N"
    full_prompt = f"""
    You are a coding assistant. Your task is to generate code based on the following prompt. Please provide only the necessary code and include explanatory comments for each step. Do not include any other text in your response.

    Prompt: {prompt}

    Only return the code and comments.
    """
    response = openai.ChatCompletion.create(
        model="gpt-3.5-turbo",
        messages=[
            {
                "role": "user",
                "content":"" + full_prompt,
            }
        ],
    )
    
    return response.choices[0].message['content'].strip()

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python ai_assistant.py <prompt>")
        sys.exit(1)
        
    prompt = sys.argv[1]
    result = generate_code(prompt)
    print(result)
