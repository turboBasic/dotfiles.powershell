
# Invoke-DefaultProfile command help
@{
	command = 'Invoke-DefaultProfile'
	synopsis = 'Resets profile to all defaults'
	description = 'Resets profile to all defaults, ie. recreates the structure of profile and add missing sections and elements'
	parameters = @{
		# XXXYYY = ''
	}
	inputs = @(
		@{
			type = ''
			description = ''
		}
	)
	outputs = @(
		@{
			type = ''
			description = ''
		}
	)
	notes = '(c) 2017 Andriy Melnyk'
	examples = @(
		@{
			#title = ''
			#introduction = ''
			code = {
                Invoke-DefaultProfile
			}
			remarks = 'Resets profile to default state'
			test = { . $args[0] }
		}
	)
	links = @(
		@{ text = 'Github repo'; URI = 'https://github.com/turboBasic/dotfiles.powershell' }
	)
}
