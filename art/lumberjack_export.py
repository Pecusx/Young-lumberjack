import json

print('gamescreen_upper')
with open('sky.atrview', 'rb') as f:
    p = f.read()
    pj=json.loads(p.decode('utf-8-sig'))
dta = [pj['Pages'][0]['View'][i*80:(i+1)*80][:64] for i in range(19)]
for l, d in enumerate(dta, 1):
    print(f'l{l}')
    print(f'  dta '+','.join([f'${d[i:i+2]}' for i in range(0, len(d), 2)]))

print('last_line_r')
with open('phase1r.atrview', 'rb') as f:
    p = f.read()
    pj=json.loads(p.decode('utf-8-sig'))
dta = pj['Pages'][0]['View']
dta = [dta[i*80:(i+1)*80][:64] for i in range(len(dta)//80)]
d = dta[-1]
print(f'  dta '+','.join([f'${d[i:i+2]}' for i in range(0, len(d), 2)]))

print('last_line_l')
with open('phase1l.atrview', 'rb') as f:
    p = f.read()
    pj=json.loads(p.decode('utf-8-sig'))
dta = pj['Pages'][0]['View']
dta = [dta[i*80:(i+1)*80][:64] for i in range(len(dta)//80)]
d = dta[-1]
print(f'  dta '+','.join([f'${d[i:i+2]}' for i in range(0, len(d), 2)]))

print("""
    .align $100
; Right animation    
gamescreen_lower1r  ; phase 1 page 1""")
with open('phase1r.atrview', 'rb') as f:
    pj=json.loads(f.read().decode('utf-8-sig'))
dta = pj['Pages'][0]['View']
dta = [dta[i*80:(i+1)*80][:64] for i in range(len(dta)//80)]
for l, d in enumerate(dta[-9:-1], 1):
    print(f'  dta '+','.join([f'${d[i:i+2]}' for i in range(0, len(d), 2)]))

print("gamescreen_lower2r  ; phase 2 page 1")
with open('phase2r.atrview', 'rb') as f:
    pj=json.loads(f.read().decode('utf-8-sig'))
dta = pj['Pages'][0]['View']
dta = [dta[i*80:(i+1)*80][:64] for i in range(len(dta)//80)]
for l, d in enumerate(dta[-9:-1], 1):
    print(f'  dta '+','.join([f'${d[i:i+2]}' for i in range(0, len(d), 2)]))

print('gamescreen_lower3r  ; phase 2 page 2')
with open('phase2r.atrview', 'rb') as f:
    pj=json.loads(f.read().decode('utf-8-sig'))
dta = pj['Pages'][1]['View']
dta = [dta[i*80:(i+1)*80][:64] for i in range(len(dta)//80)]
for l, d in enumerate(dta[-9:-1], 1):
    print(f'  dta '+','.join([f'${d[i:i+2]}' for i in range(0, len(d), 2)]))

print('gamescreen_lower4r  ; phase 2 page 3')
with open('phase2r.atrview', 'rb') as f:
    pj=json.loads(f.read().decode('utf-8-sig'))
dta = pj['Pages'][2]['View']
dta = [dta[i*80:(i+1)*80][:64] for i in range(len(dta)//80)]
for l, d in enumerate(dta[-9:-1], 1):
    print(f'  dta '+','.join([f'${d[i:i+2]}' for i in range(0, len(d), 2)]))

print('gamescreen_lower5r  ; phase 2 page 4')
with open('phase2r.atrview', 'rb') as f:
    pj=json.loads(f.read().decode('utf-8-sig'))
dta = pj['Pages'][3]['View']
dta = [dta[i*80:(i+1)*80][:64] for i in range(len(dta)//80)]
for l, d in enumerate(dta[-9:-1], 1):
    print(f'  dta '+','.join([f'${d[i:i+2]}' for i in range(0, len(d), 2)]))

print('gamescreen_lower6r  ; phase 3 page 1')
with open('phase3r.atrview', 'rb') as f:
    pj=json.loads(f.read().decode('utf-8-sig'))
dta = pj['Pages'][0]['View']
dta = [dta[i*80:(i+1)*80][:64] for i in range(len(dta)//80)]
for l, d in enumerate(dta[-9:-1], 1):
    print(f'  dta '+','.join([f'${d[i:i+2]}' for i in range(0, len(d), 2)]))

print('gamescreen_lower7r  ; phase 3 page 2')
with open('phase3r.atrview', 'rb') as f:
    pj=json.loads(f.read().decode('utf-8-sig'))
dta = pj['Pages'][1]['View']
dta = [dta[i*80:(i+1)*80][:64] for i in range(len(dta)//80)]
for l, d in enumerate(dta[-9:-1], 1):
    print(f'  dta '+','.join([f'${d[i:i+2]}' for i in range(0, len(d), 2)]))

print('gamescreen_lower8r  ; phase 3 page 3')
with open('phase3r.atrview', 'rb') as f:
    pj=json.loads(f.read().decode('utf-8-sig'))
dta = pj['Pages'][2]['View']
dta = [dta[i*80:(i+1)*80][:64] for i in range(len(dta)//80)]
for l, d in enumerate(dta[-9:-1], 1):
    print(f'  dta '+','.join([f'${d[i:i+2]}' for i in range(0, len(d), 2)]))

print('gamescreen_lower9r  ; phase 3 page 4')
with open('phase3r.atrview', 'rb') as f:
    pj=json.loads(f.read().decode('utf-8-sig'))
dta = pj['Pages'][3]['View']
dta = [dta[i*80:(i+1)*80][:64] for i in range(len(dta)//80)]
for l, d in enumerate(dta[-9:-1], 1):
    print(f'  dta '+','.join([f'${d[i:i+2]}' for i in range(0, len(d), 2)]))

print('gamescreen_lower10r  ; phase 3 page 5')
with open('phase3r.atrview', 'rb') as f:
    pj=json.loads(f.read().decode('utf-8-sig'))
dta = pj['Pages'][4]['View']
dta = [dta[i*80:(i+1)*80][:64] for i in range(len(dta)//80)]
for l, d in enumerate(dta[-9:-1], 1):
    print(f'  dta '+','.join([f'${d[i:i+2]}' for i in range(0, len(d), 2)]))

print("""
; left animation    
gamescreen_lower1l  ; phase 1 page 1""")
with open('phase1l.atrview', 'rb') as f:
    pj=json.loads(f.read().decode('utf-8-sig'))
dta = pj['Pages'][0]['View']
dta = [dta[i*80:(i+1)*80][:64] for i in range(len(dta)//80)]
for l, d in enumerate(dta[-9:-1], 1):
    print(f'  dta '+','.join([f'${d[i:i+2]}' for i in range(0, len(d), 2)]))

print('gamescreen_lower2l  ; phase 2 page 1')
with open('phase2l.atrview', 'rb') as f:
    pj=json.loads(f.read().decode('utf-8-sig'))
dta = pj['Pages'][0]['View']
dta = [dta[i*80:(i+1)*80][:64] for i in range(len(dta)//80)]
for l, d in enumerate(dta[-9:-1], 1):
    print(f'  dta '+','.join([f'${d[i:i+2]}' for i in range(0, len(d), 2)]))

print('gamescreen_lower3l  ; phase 2 page 2')
with open('phase2l.atrview', 'rb') as f:
    pj=json.loads(f.read().decode('utf-8-sig'))
dta = pj['Pages'][1]['View']
dta = [dta[i*80:(i+1)*80][:64] for i in range(len(dta)//80)]
for l, d in enumerate(dta[-9:-1], 1):
    print(f'  dta '+','.join([f'${d[i:i+2]}' for i in range(0, len(d), 2)]))

print('gamescreen_lower4l  ; phase 2 page 3')
with open('phase2l.atrview', 'rb') as f:
    pj=json.loads(f.read().decode('utf-8-sig'))
dta = pj['Pages'][2]['View']
dta = [dta[i*80:(i+1)*80][:64] for i in range(len(dta)//80)]
for l, d in enumerate(dta[-9:-1], 1):
    print(f'  dta '+','.join([f'${d[i:i+2]}' for i in range(0, len(d), 2)]))

print('gamescreen_lower5l  ; phase 2 page 4')
with open('phase2l.atrview', 'rb') as f:
    pj=json.loads(f.read().decode('utf-8-sig'))
dta = pj['Pages'][3]['View']
dta = [dta[i*80:(i+1)*80][:64] for i in range(len(dta)//80)]
for l, d in enumerate(dta[-9:-1], 1):
    print(f'  dta '+','.join([f'${d[i:i+2]}' for i in range(0, len(d), 2)]))

print('gamescreen_lower6l  ; phase 3 page 1')
with open('phase3l.atrview', 'rb') as f:
    pj=json.loads(f.read().decode('utf-8-sig'))
dta = pj['Pages'][0]['View']
dta = [dta[i*80:(i+1)*80][:64] for i in range(len(dta)//80)]
for l, d in enumerate(dta[-9:-1], 1):
    print(f'  dta '+','.join([f'${d[i:i+2]}' for i in range(0, len(d), 2)]))

print('gamescreen_lower7l  ; phase 3 page 2')
with open('phase3l.atrview', 'rb') as f:
    pj=json.loads(f.read().decode('utf-8-sig'))
dta = pj['Pages'][1]['View']
dta = [dta[i*80:(i+1)*80][:64] for i in range(len(dta)//80)]
for l, d in enumerate(dta[-9:-1], 1):
    print(f'  dta '+','.join([f'${d[i:i+2]}' for i in range(0, len(d), 2)]))

print('gamescreen_lower8l  ; phase 3 page 3')
with open('phase3l.atrview', 'rb') as f:
    pj=json.loads(f.read().decode('utf-8-sig'))
dta = pj['Pages'][2]['View']
dta = [dta[i*80:(i+1)*80][:64] for i in range(len(dta)//80)]
for l, d in enumerate(dta[-9:-1], 1):
    print(f'  dta '+','.join([f'${d[i:i+2]}' for i in range(0, len(d), 2)]))

print('gamescreen_lower9l  ; phase 3 page 4')
with open('phase3l.atrview', 'rb') as f:
    pj=json.loads(f.read().decode('utf-8-sig'))
dta = pj['Pages'][3]['View']
dta = [dta[i*80:(i+1)*80][:64] for i in range(len(dta)//80)]
for l, d in enumerate(dta[-9:-1], 1):
    print(f'  dta '+','.join([f'${d[i:i+2]}' for i in range(0, len(d), 2)]))

print('gamescreen_lower10l  ; phase 3 page 5')
with open('phase3l.atrview', 'rb') as f:
    pj=json.loads(f.read().decode('utf-8-sig'))
dta = pj['Pages'][3]['View']
dta = [dta[i*80:(i+1)*80][:64] for i in range(len(dta)//80)]
for l, d in enumerate(dta[-9:-1], 1):
    print(f'  dta '+','.join([f'${d[i:i+2]}' for i in range(0, len(d), 2)]))
