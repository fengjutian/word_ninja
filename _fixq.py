with open(r'D:\github\word_ninja\_gen_da.py') as f: 
    content = f.read() 
content = content.replace(chr(92)+chr(34), chr(34)) 
with open(r'D:\github\word_ninja\_gen_da.py', 'w') as f: 
    f.write(content)  
print('fixed') 
