from transformers import AutoModelForCausalLM, AutoTokenizer

# Load model and tokenizer
model_name = "Salesforce/codegen-2B-mono"  # Replace with your preferred model
model = AutoModelForCausalLM.from_pretrained(model_name)
tokenizer = AutoTokenizer.from_pretrained(model_name)

# Function to generate code
def generate_code(prompt):
    inputs = tokenizer(prompt, return_tensors="pt")
    outputs = model.generate(inputs["input_ids"], max_length=100)
    return tokenizer.decode(outputs[0], skip_special_tokens=True)

# Example usage
prompt = "Write a Python script that reads a CSV file and prints its content."
code = generate_code(prompt)
print("Generated Code:")
print(code)
