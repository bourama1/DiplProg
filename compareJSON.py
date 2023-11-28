import json
import tkinter as tk
from tkinter import filedialog

def load_json_file():
    file_path = filedialog.askopenfilename(title="Select a JSON file", filetypes=[("JSON files", "*.json")])
    if file_path:
        with open(file_path, 'r') as file:
            data = json.load(file)
        return data
    return None

def compare_json_files():
    print("Select the first JSON file:")
    data1 = load_json_file()
    if data1 is None:
        print("No file selected. Exiting.")
        return

    print("Select the second JSON file:")
    data2 = load_json_file()
    if data2 is None:
        print("No file selected. Exiting.")
        return

    if data1 == data2:
        print("The JSON files are identical.")
    else:
        print("The JSON files are different.")

if __name__ == "__main__":
    root = tk.Tk()
    root.withdraw()  # Hide the main window

    compare_json_files()
