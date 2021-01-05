vars = {}
rules = []

# read info from file
with open('input.txt') as input:
	for line in input:
		if 'var' in line:
			vars[line[line.index(' ') + 1:line.index('=')]] = list(map(int, line[line.index('{')+1:line.index('}')].split(',')))

		else:
			rules.append(line.strip('\n'))

# build much longer transition table
