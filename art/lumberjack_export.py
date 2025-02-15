import json

def load_atrview(filename: str, page: int = 1) -> list[str]:
    with open(filename, 'rb') as f:
        dta = json.loads(f.read().decode('utf-8-sig'))['Pages'][page-1]['View']
        return [dta[i*80:(i+1)*80][:64] for i in range(len(dta)//80)]

def print_lines(dta, line_from: int, line_to:int):
    for d in dta[line_from:line_to]:
        print(f'  dta ' + ','.join([f'${d[i:i + 2]}' for i in range(0, len(d), 2)]))


print('gamescreen_upper')
dta = load_atrview('sky.atrview')
print("power_bar")
print_lines(dta, 0,2)
print("branch0")
print_lines(dta, 2,7)
print("branch1")
print_lines(dta, 7,12)
print("branch2")
print_lines(dta, 12,17)
print("branch3")
print_lines(dta, 17,22)

print()
print('last_line_r')
dta = load_atrview('phase1r.atrview')
d = dta[-1]
print(f'  dta '+','.join([f'${d[i:i+2]}' for i in range(0, len(d), 2)]))

print('last_line_l')
dta = load_atrview('phase1l.atrview')
d = dta[-1]
print(f'  dta '+','.join([f'${d[i:i+2]}' for i in range(0, len(d), 2)]))

print("""
    .align $100
; Right animation    
gamescreen_lower1r  ; phase 1 page 1""")
dta = load_atrview('phase1r.atrview')
for l, d in enumerate(dta[-9:-1], 1):
    print(f'  dta '+','.join([f'${d[i:i+2]}' for i in range(0, len(d), 2)]))

print("gamescreen_lower2r  ; phase 2 page 1")
dta = load_atrview('phase2r.atrview')
for l, d in enumerate(dta[-9:-1], 1):
    print(f'  dta '+','.join([f'${d[i:i+2]}' for i in range(0, len(d), 2)]))

print('gamescreen_lower3r  ; phase 2 page 2')
dta = load_atrview('phase2r.atrview', page=2)
print_lines(dta, -9, -1)

print('gamescreen_lower4r  ; phase 2 page 3')
dta = load_atrview('phase2r.atrview', page=3)
print_lines(dta, -9, -1)

print('gamescreen_lower5r  ; phase 2 page 4')
dta = load_atrview('phase2r.atrview', page=4)
print_lines(dta, -9, -1)

print('gamescreen_lower6r  ; phase 3 page 1')
dta = load_atrview('phase3r.atrview', page=1)
print_lines(dta, -9, -1)

print('gamescreen_lower7r  ; phase 3 page 2')
dta = load_atrview('phase3r.atrview', page=2)
print_lines(dta, -9, -1)

print('gamescreen_lower8r  ; phase 3 page 3')
dta = load_atrview('phase3r.atrview', page=3)
print_lines(dta, -9, -1)

print('gamescreen_lower9r  ; phase 3 page 4')
dta = load_atrview('phase3r.atrview', page=4)
print_lines(dta, -9, -1)

print('gamescreen_lower10r  ; phase 3 page 5')
dta = load_atrview('phase3r.atrview', page=5)
print_lines(dta, -9, -1)

print("""
; left animation    
gamescreen_lower1l  ; phase 1 page 1""")
# pj = load_atrview('phase1l.atrview')
# print_lines(dta, -9, -1)
with open('phase1l.atrview', 'rb') as f:
    pj=json.loads(f.read().decode('utf-8-sig'))
dta = pj['Pages'][0]['View']
dta = [dta[i*80:(i+1)*80][:64] for i in range(len(dta)//80)]
for l, d in enumerate(dta[-9:-1], 1):
    print(f'  dta '+','.join([f'${d[i:i+2]}' for i in range(0, len(d), 2)]))

print('gamescreen_lower2l  ; phase 2 page 1')
dta = load_atrview('phase2l.atrview', page=1)
print_lines(dta, -9, -1)

print('gamescreen_lower3l  ; phase 2 page 2')
dta = load_atrview('phase2l.atrview', page=2)
print_lines(dta, -9, -1)

print('gamescreen_lower4l  ; phase 2 page 3')
dta = load_atrview('phase2l.atrview', page=3)
print_lines(dta, -9, -1)

print('gamescreen_lower5l  ; phase 2 page 4')
dta = load_atrview('phase2l.atrview', page=4)
print_lines(dta, -9, -1)

print('gamescreen_lower6l  ; phase 3 page 1')
dta = load_atrview('phase3l.atrview', page=1)
print_lines(dta, -9, -1)

print('gamescreen_lower7l  ; phase 3 page 2')
dta = load_atrview('phase3l.atrview', page=2)
print_lines(dta, -9, -1)

print('gamescreen_lower8l  ; phase 3 page 3')
dta = load_atrview('phase3l.atrview', page=3)
print_lines(dta, -9, -1)

print('gamescreen_lower9l  ; phase 3 page 4')
dta = load_atrview('phase3l.atrview', page=4)
print_lines(dta, -9, -1)

print('gamescreen_lower10l  ; phase 3 page 5')
dta = load_atrview('phase3l.atrview', page=5)
print_lines(dta, -9, -1)
