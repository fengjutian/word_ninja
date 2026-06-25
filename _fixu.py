with open(r'D:\github\word_ninja\_gen_da.py') as f: 
    content = f.read() 
old = r\"'\u{1F422}'\" 
new = r\"'\u{1F422}'\" 
content = content.replace(old, new) 
with open(r'D:\github\word_ninja\_gen_da.py', 'w') as f: 
    f.write(content)  
print('fixed') 
