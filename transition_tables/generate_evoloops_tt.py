vars = {}
sorted_keys = []
rules = []
final_rules = []

# replaces variables in a rule with desired values
# variables is a sub-dictionary that contains the vars that need to be replaced and the values with which the vars should be replaced
def replace_vars(rule, variables):
	# base case: last variables to be replaced
	if len(variables) == 1:
		var = list(variables.keys())[0]
		for num in variables:
			final_rules.append(rule.replace(var, num))



# read info from file
with open('input.txt') as input:
	for line in input:
		if 'var' in line:
			vars[line[line.index(' ') + 1:line.index('=')]] = list(map(int, line[line.index('{')+1:line.index('}')].split(',')))

		else:
			rules.append(line.strip('\n').split(','))

# Sort keys by length with longest keys first
# keys are either length 2 or 1 so easier to use two for loops
for key in vars:
	if len(key) == 2:
		sorted_keys.append(key)
for key in vars:
	if len(key) == 1:
		sorted_keys.append(key)

# build much longer transition table
for rule in rules:
	variables = {}

	for key in sorted_keys:
		if key in rule:
			variables[key] = vars[key]

	# if rule has no variables, just add to final_rules
	if len(variables) == 0:
		final_rules.append(''.join(rule))

	else:
		# Function call to deal with cross product
		replace_vars(rule, variables)

print(final_rules)
print('how many rules?', len(final_rules))
