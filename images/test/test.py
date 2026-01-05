import re

def detect_hardcoded_secrets(source_code):
    # Regex pour détecter des chaînes potentiellement dangereuses (clés API, mots de passe, etc.)
    secret_patterns = [
        r'["\']?(?:key|token|secret|password)["\']?\s*[:=]\s*["\'][a-zA-Z0-9]{16,}["\']',
        r'["\']?api_key["\']?\s*[:=]\s*["\'][a-zA-Z0-9]{16,}["\']',
    ]

    vulnerabilities = []
    for i, line in enumerate(source_code.split("\n"), 1):
        for pattern in secret_patterns:
            if re.search(pattern, line):
                vulnerabilities.append((i, "Hardcoded secret or API key detected"))

    return vulnerabilities


# Exemple d'utilisation
source_code = """
API_KEY = "123456789abcdef123456789adc"
password = "mysecretpassword0"
"""
vulnerabilities = detect_hardcoded_secrets(source_code)
for line, message in vulnerabilities:
    print(f"Line {line}: {message}")
