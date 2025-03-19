import json
import os

def retain_fields(dict_list, fields_to_retain):
    result = []
    
    for item in dict_list:
        filtered_item = {key: item[key] for key in fields_to_retain if key in item}
        result.append(filtered_item)
    
    return result

for file in os.listdir('/mnt/k/Datasets'):

    if file.endswith(".json"):
        print(f"Processing {file}")
        # Read the text file
        with open(file, 'r') as f:
            dict_string = f.read()

        # Parse the string
        dict_string = '[' + dict_string[:-1] + ']\n'
        my_dict = json.loads(dict_string)
        
        filtered_dict = retain_fields(my_dict, ['created_at', 'id_str', 'text', 'user', 'geo', 'coordinates', 'place'])

        # Convert to JSON
        #json_string = json.dumps(filtered_dict)
        

        # Write to a file (optional)
        with open(f"{file}", 'w') as file:
            json.dump(filtered_dict, file)
