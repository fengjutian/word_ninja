with open(r'D:\github\word_ninja\word_ninja\apps\desktop_app\pubspec.yaml') as f: 
    lines = [l for l in f if 'ai_tutor' not in l] 
with open(r'D:\github\word_ninja\word_ninja\apps\desktop_app\pubspec.yaml', 'w') as f: 
    f.writelines(lines) 
print('done')  
