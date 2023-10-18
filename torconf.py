with open('/tor-browser/Browser/TorBrowser/Data/Tor/torcc', 'r') as torcc_file:
    torcc_content = torcc_file.read()
excluded_countries = input("Введите коды стран для исключения (разделите их запятой, например: BY,RU): ").split(',')
exclude_string = ','.join(excluded_countries)


new_torcc_content = torcc_content + f"ExitNodes {{US}}\nStrictExitNodes 1\nExcludeNodes {exclude_string}\n"

with open('/tor-browser/Browser/TorBrowser/Data/Tor/torcc', 'w') as torcc_file:
    torcc_file.write(new_torcc_content)
