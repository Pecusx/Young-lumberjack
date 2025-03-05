import json

color_labels_used = set()


def load_atrview(filename: str, page: int = 1) -> list[str]:
    with open(filename, 'rb') as f:
        full_json = json.loads(f.read().decode('utf-8-sig'))
        dta = full_json['Pages'][page - 1]['View']
        # very unpythonic side effect - printing colors consts
        const_name = filename.replace('.atrview', '')
        cols = full_json['Colors']
        for i, val in enumerate([cols[i:i + 2] for i in range(0, len(cols), 2)]):
            color_label = const_name + 'p' + str(page) + 'c' + str(i)
            if color_label not in color_labels_used:
                print(color_label + ' = $' + val)
                color_labels_used.add(color_label)
        return [dta[i * 80:(i + 1) * 80][:64] for i in range(len(dta) // 80)]


def print_lines(dta, line_from: int, line_to: int):
    for d in dta[line_from:line_to]:
        print(f'  dta ' + ','.join([f'${d[i:i + 2]}' for i in range(0, len(d), 2)]))


print('gamescreen_upper')
dta = load_atrview('sky.atrview')
print("power_bar")
print_lines(dta, 0, 2)
print("branch0")
print_lines(dta, 2, 7)
print("branch1")
print_lines(dta, 7, 12)
print("branch2")
print_lines(dta, 12, 17)
# print("branch3")
# print_lines(dta, 17,22)

print()
print('last_line_r')
dta = load_atrview('phase1r.atrview')
d = dta[-1]
print(f'  dta ' + ','.join([f'${d[i:i + 2]}' for i in range(0, len(d), 2)]))

print('last_line_l')
dta = load_atrview('phase1l.atrview')
d = dta[-1]
print(f'  dta ' + ','.join([f'${d[i:i + 2]}' for i in range(0, len(d), 2)]))

print('last_line_RIP')
dta = load_atrview('rip.atrview')
d = dta[-1]
print(f'  dta ' + ','.join([f'${d[i:i + 2]}' for i in range(0, len(d), 2)]))

print("""
    .align $100
; Right animation    
gamescreen_r_ph1p1  ; phase 1 page 1""")
dta = load_atrview('phase1r.atrview')
for l, d in enumerate(dta[-9:-1], 1):
    print(f'  dta ' + ','.join([f'${d[i:i + 2]}' for i in range(0, len(d), 2)]))

print('gamescreen_r_ph1p2  ; phase 1 page 2')
dta = load_atrview('phase1r.atrview', page=2)
print_lines(dta, -9, -1)

print("gamescreen_r_ph2p1  ; phase 2 page 1")
dta = load_atrview('phase2r.atrview')
for l, d in enumerate(dta[-9:-1], 1):
    print(f'  dta ' + ','.join([f'${d[i:i + 2]}' for i in range(0, len(d), 2)]))

print('gamescreen_r_ph2p2  ; phase 2 page 2')
dta = load_atrview('phase2r.atrview', page=2)
print_lines(dta, -9, -1)

print('gamescreen_r_ph2p3  ; phase 2 page 3')
dta = load_atrview('phase2r.atrview', page=3)
print_lines(dta, -9, -1)

print('gamescreen_r_ph2p4  ; phase 2 page 4')
dta = load_atrview('phase2r.atrview', page=4)
print_lines(dta, -9, -1)

print('gamescreen_r_ph2p5  ; phase 2 page 5')
dta = load_atrview('phase2r.atrview', page=5)
print_lines(dta, -9, -1)

print('gamescreen_r_ph2p6  ; phase 2 page 6')
dta = load_atrview('phase2r.atrview', page=6)
print_lines(dta, -9, -1)

print('gamescreen_r_ph2p7  ; phase 2 page 7')
dta = load_atrview('phase2r.atrview', page=7)
print_lines(dta, -9, -1)

print('gamescreen_r_ph2p8  ; phase 2 page 8')
dta = load_atrview('phase2r.atrview', page=8)
print_lines(dta, -9, -1)

print('gamescreen_r_ph3p1  ; phase 3 page 1')
dta = load_atrview('phase3r.atrview', page=1)
print_lines(dta, -9, -1)

print('gamescreen_r_ph3p2  ; phase 3 page 2')
dta = load_atrview('phase3r.atrview', page=2)
print_lines(dta, -9, -1)

print('gamescreen_r_ph3p3  ; phase 3 page 3')
dta = load_atrview('phase3r.atrview', page=3)
print_lines(dta, -9, -1)

print('gamescreen_r_ph3p4  ; phase 3 page 4')
dta = load_atrview('phase3r.atrview', page=4)
print_lines(dta, -9, -1)

print('gamescreen_r_ph3p5  ; phase 3 page 5')
dta = load_atrview('phase3r.atrview', page=5)
print_lines(dta, -9, -1)

print('gamescreen_r_ph3p6  ; phase 3 page 6')
dta = load_atrview('phase3r.atrview', page=6)
print_lines(dta, -9, -1)

print('gamescreen_r_ph3p7  ; phase 3 page 7')
dta = load_atrview('phase3r.atrview', page=7)
print_lines(dta, -9, -1)

print('gamescreen_r_ph3p8  ; phase 3 page 8')
dta = load_atrview('phase3r.atrview', page=8)
print_lines(dta, -9, -1)

print('gamescreen_r_ph3p9  ; phase 3 page 9')
dta = load_atrview('phase3r.atrview', page=9)
print_lines(dta, -9, -1)

print('gamescreen_r_ph3p10  ; phase 3 page 10')
dta = load_atrview('phase3r.atrview', page=10)
print_lines(dta, -9, -1)

print('gamescreen_r_ph3p11  ; phase 3 page 11')
dta = load_atrview('phase3r.atrview', page=11)
print_lines(dta, -9, -1)

print('gamescreen_r_ph3p12  ; phase 3 page 12')
dta = load_atrview('phase3r.atrview', page=12)
print_lines(dta, -9, -1)

print('gamescreen_r_ph3p13  ; phase 3 page 13')
dta = load_atrview('phase3r.atrview', page=13)
print_lines(dta, -9, -1)

print('gamescreen_r_ph3p14  ; phase 3 page 14')
dta = load_atrview('phase3r.atrview', page=14)
print_lines(dta, -9, -1)

print("""
; left animation    
gamescreen_l_ph1p1  ; phase 1 page 1""")
# pj = load_atrview('phase1l.atrview')
# print_lines(dta, -9, -1)
with open('phase1l.atrview', 'rb') as f:
    pj = json.loads(f.read().decode('utf-8-sig'))
dta = pj['Pages'][0]['View']
dta = [dta[i * 80:(i + 1) * 80][:64] for i in range(len(dta) // 80)]
for l, d in enumerate(dta[-9:-1], 1):
    print(f'  dta ' + ','.join([f'${d[i:i + 2]}' for i in range(0, len(d), 2)]))

print('gamescreen_l_ph1p2  ; phase 1 page 2')
dta = load_atrview('phase1l.atrview', page=2)
print_lines(dta, -9, -1)

print('gamescreen_l_ph2p1  ; phase 2 page 1')
dta = load_atrview('phase2l.atrview', page=1)
print_lines(dta, -9, -1)

print('gamescreen_l_ph2p2  ; phase 2 page 2')
dta = load_atrview('phase2l.atrview', page=2)
print_lines(dta, -9, -1)

print('gamescreen_l_ph2p3  ; phase 2 page 3')
dta = load_atrview('phase2l.atrview', page=3)
print_lines(dta, -9, -1)

print('gamescreen_l_ph2p4  ; phase 2 page 4')
dta = load_atrview('phase2l.atrview', page=4)
print_lines(dta, -9, -1)

print('gamescreen_l_ph2p5  ; phase 2 page 5')
dta = load_atrview('phase2l.atrview', page=5)
print_lines(dta, -9, -1)

print('gamescreen_l_ph2p6  ; phase 2 page 6')
dta = load_atrview('phase2l.atrview', page=6)
print_lines(dta, -9, -1)

print('gamescreen_l_ph2p7  ; phase 2 page 7')
dta = load_atrview('phase2l.atrview', page=7)
print_lines(dta, -9, -1)

print('gamescreen_l_ph2p8  ; phase 2 page 8')
dta = load_atrview('phase2l.atrview', page=8)
print_lines(dta, -9, -1)

print('gamescreen_l_ph3p1  ; phase 3 page 1')
dta = load_atrview('phase3l.atrview', page=1)
print_lines(dta, -9, -1)

print('gamescreen_l_ph3p2  ; phase 3 page 2')
dta = load_atrview('phase3l.atrview', page=2)
print_lines(dta, -9, -1)

print('gamescreen_l_ph3p3  ; phase 3 page 3')
dta = load_atrview('phase3l.atrview', page=3)
print_lines(dta, -9, -1)

print('gamescreen_l_ph3p4  ; phase 3 page 4')
dta = load_atrview('phase3l.atrview', page=4)
print_lines(dta, -9, -1)

print('gamescreen_l_ph3p5  ; phase 3 page 5')
dta = load_atrview('phase3l.atrview', page=5)
print_lines(dta, -9, -1)

print('gamescreen_l_ph3p6  ; phase 3 page 6')
dta = load_atrview('phase3l.atrview', page=6)
print_lines(dta, -9, -1)

print('gamescreen_l_ph3p7  ; phase 3 page 7')
dta = load_atrview('phase3l.atrview', page=7)
print_lines(dta, -9, -1)

print('gamescreen_l_ph3p8  ; phase 3 page 8')
dta = load_atrview('phase3l.atrview', page=8)
print_lines(dta, -9, -1)

print('gamescreen_l_ph3p9  ; phase 3 page 9')
dta = load_atrview('phase3l.atrview', page=9)
print_lines(dta, -9, -1)

print('gamescreen_l_ph3p10  ; phase 3 page 10')
dta = load_atrview('phase3l.atrview', page=10)
print_lines(dta, -9, -1)

print('gamescreen_l_ph3p11  ; phase 3 page 11')
dta = load_atrview('phase3l.atrview', page=11)
print_lines(dta, -9, -1)

print('gamescreen_l_ph3p12  ; phase 3 page 12')
dta = load_atrview('phase3l.atrview', page=12)
print_lines(dta, -9, -1)

print('gamescreen_l_ph3p13  ; phase 3 page 13')
dta = load_atrview('phase3l.atrview', page=13)
print_lines(dta, -9, -1)

print('gamescreen_l_ph3p14  ; phase 3 page 14')
dta = load_atrview('phase3l.atrview', page=14)
print_lines(dta, -9, -1)

print("""
; RIP screens    
RIPscreen_l_nobranch  ; page 1""")
with open('rip.atrview', 'rb') as f:
    pj = json.loads(f.read().decode('utf-8-sig'))
dta = pj['Pages'][0]['View']
dta = [dta[i * 80:(i + 1) * 80][:64] for i in range(len(dta) // 80)]
for l, d in enumerate(dta[-9:-1], 1):
    print(f'  dta ' + ','.join([f'${d[i:i + 2]}' for i in range(0, len(d), 2)]))

print('RIPscreen_r_nobranch  ; page 2')
dta = load_atrview('rip.atrview', page=2)
print_lines(dta, -9, -1)

print('RIPscreen_l_branch  ; page 3')
dta = load_atrview('rip.atrview', page=3)
print_lines(dta, -9, -1)

print('RIPscreen_r_branch  ; page 4')
dta = load_atrview('rip.atrview', page=4)
print_lines(dta, -9, -1)

print('RIPscreen_l_Rbranch  ; page 5')
dta = load_atrview('rip.atrview', page=5)
print_lines(dta, -9, -1)

print('RIPscreen_r_Lbranch  ; page 6')
dta = load_atrview('rip.atrview', page=6)
print_lines(dta, -9, -1)
