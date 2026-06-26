import os  
path = r\"word_ninja\apps\desktop_app\lib\widgets\window_title_bar.dart\"  
os.makedirs(os.path.dirname(path), exist_ok=True)  
with open(path, \"w\", encoding=\"utf-8\") as f:  
    f.write(\"// test\")  
print(\"done\") 
