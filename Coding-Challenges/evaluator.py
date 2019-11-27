def is_number(s):
    try:
        float(s)
        return True
    except ValueError:
        return False

def do_op(op, a, b):
    if op == '+':
        return b + a
    elif op == '-':
        return b - a
    elif op == '*':
        return b * a
    elif op == '/':
        if a != 0:
            return b / a
        else:
            print('Division by 0!')
            return 0
    elif op == '^':
        return b ** a
    else:
        print('Error op:' + op)
        return 0

def evaluate_rpn(rpn):
    stack = []
    for elem in rpn:
        if is_number(elem):
            stack = [float(elem)] + stack
        else:
            if (len(stack) >= 2):
                a, b, *tail = stack
                stack = [do_op(elem, a, b)] + tail
            else:
                print('Not enough stack: ' + str(rpn))
                return 0
    if (len(stack) == 1):
        return stack[0]
    else:
        print('Wrong final stack: ' + str(rpn))
        return 0

pr_map = {'+': 1, '-': 1, '*': 2, '/': 2, '^': 3, '(': -100}

def priority(op):
    if op in pr_map:
        return pr_map[op]
    else:
        print('Op not in priority map: ' + op)
        return 0

def add_to_rpn(elem, rpn):
    if elem != '(' and elem != ')':
        return rpn + [elem]
    else:
        return rpn

def push_op_to_stack(op, stack):
    rpn = []
    if op == '(':
        stack = [op] + stack
    elif op == ')':
        while stack[0] != '(':
            head, *stack = stack
            rpn = add_to_rpn(head, rpn)
        head, *stack = stack
    else:
        while len(stack) > 0 and priority(stack[0]) >= priority(op):
            head, *stack = stack
            rpn = add_to_rpn(head, rpn)
        stack = [op] + stack
    return (stack, rpn)

def generate_part(x, one, five, ten):
    if x == 0:
        return ''
    elif x < 4:
        return one * x
    elif x == 4:
        return one + five
    elif x < 9:
        return five + one * (x - 5)
    else:
        return one + ten

def to_roman(num):
    num = int(num)
    ones = num % 10
    ones = generate_part(ones, 'I', 'V', 'X')
    tens = num // 10 % 10
    tens = generate_part(tens, 'X', 'L', 'C')
    hnds = num // 100 % 10
    hnds = generate_part(hnds, 'C', 'D', 'M')
    ths = num // 1000
    ths = 'M' * ths
    return ths + hnds + tens + ones

def from_roman(elem):
    for i in range(10000):
        if (to_roman(i) == elem):
            return i
    print('Unknown roman: ' + elem)
    return 0

def from_romans(elems):
    newelems = []
    rom = False
    for elem in elems:
        if 'I' in elem or 'V' in elem or 'X' in elem or 'L' in elem or 'C' in elem or 'D' in elem or 'E' in elem:
            rom = True
            newelems += [str(from_roman(elem))]
        else:
            newelems += [elem]
    return (rom, newelems)

units = {'seconds': 1, 'minutes': 60, 'hours': 3600, 'days': 86400,
         'centimeters': 0.01, 'meters': 1, 'kilometers': 1000,
         'inches': 0.0254, 'feet': 0.3048, 'yards': 0.9144, 'miles': 1609.34,
         'second': 1, 'minute': 60, 'hour': 3600, 'day': 86400,
         'centimeter': 0.01, 'meter': 1, 'kilometer': 1000,
         'inche': 0.0254, 'foot': 0.3048, 'yard': 0.9144, 'mile': 1609.34}

def preprocess_units(elems):
    newelems = []
    last = False
    suffix = ''
    for elem in elems:
        if elem in units:
            if not last:
                newelems += ['*', str(units[elem])]
            else:
                suffix = ' ' + elem
                newelems += ['/', str(units[elem])]
        elif elem == 'in':
            last = True
        else:
            newelems += [elem]
    return (suffix, newelems)

def evaluate_expression(query):
    elems = query.split()
    (is_roman, elems) = from_romans(elems)
    (suffix, elems) = preprocess_units(elems)
    rpn = []
    stack = []
    for elem in elems:
        if is_number(elem):
            rpn = rpn + [elem]
        else:
            stack, newrpn = push_op_to_stack(elem, stack)
            rpn = rpn + newrpn
    for elem in stack:
        rpn = add_to_rpn(elem, rpn)
    ans = evaluate_rpn(rpn)
    if is_roman:
        ans = to_roman(ans)
    else:
        ans = str(ans)
    return ans + suffix

print(evaluate_expression('4 ^ 2 - 3 * ( 5 - 6 ) / 2'))
print(evaluate_expression('V centimeters * IV * ( I minute - X seconds ) / II seconds in meters'))