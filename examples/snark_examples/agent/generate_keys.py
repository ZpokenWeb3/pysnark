from solders.keypair import Keypair
import json

keypair = Keypair()
keypair_json = json.dumps(list(bytes(keypair)))  

print("New agent key:")
print(keypair_json)
