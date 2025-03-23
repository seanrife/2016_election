from transformers import AutoModelForSequenceClassification, AutoTokenizer, pipeline
import os
import json

model = AutoModelForSequenceClassification.from_pretrained('NLP-LTU/bertweet-large-sexism-detector')
tokenizer = AutoTokenizer.from_pretrained('NLP-LTU/bertweet-large-sexism-detector')
classifier = pipeline("text-classification", model=model, tokenizer=tokenizer)

predictions = []

for file in os.listdir('/home/sean/2016_election'):
     if file.endswith(".json"):
        print(f"Processing {file}")
        # Read the text file
        with open('/home/sean/2016_election/'+file, 'r') as f:
            texts = []
            dates = []
            ids = []
            names = []
            screennames = []
            locations = []
            followerss = []
            statusess = []
            geos = []
            coordinatess = []
            places = []
            data = json.loads(f.read())
            for datum in data:
                if len(datum) > 0:
                    texts.append(datum.get('text'))
                    dates.append(datum.get('created_at'))
                    ids.append(datum.get('id_str'))
                    names.append(datum.get('user').get('name'))
                    screennames.append(datum.get('user').get('screen_name'))
                    locations.append(datum.get('user').get('location'))
                    followerss.append(datum.get('user').get('followers_count'))
                    statusess.append(datum.get('user').get('statuses_count'))
                    geos.append(datum.get('geo'))
                    coordinatess.append(datum.get('coordinates'))
                    places.append(datum.get('place'))
            print("Classifying...")
            print(len(texts))
            print(len(dates))
            print(len(ids))
            print(len(names))
            print(len(screennames))
            print(len(locations))
            print(len(followerss))
            print(len(statusess))
            print(len(geos))
            print(len(coordinatess))
            print(len(places))
            predictions = classifier(texts, batch_size=256)
        with open('/home/sean/2016_election/' + file + '.tsv', 'w') as w:
            w.write("sexist\ttext\tdate\tids[i]\tname\tscreenname\tlocation\tfollowers\tstatuses\tgeo\tcoordinates\tplace\n")
            for i, record in enumerate(predictions):
                sexist = 0
                text = texts[i].replace("\n", " ").replace("\r", " ")
                if record['label'] == 'sexist':
                    sexist = 1
                w.write(f"{sexist}\t{text}\t{dates[i]}\t{ids[i]}\t{names[i]}\t{screennames[i]}\t{locations[i]}\t{followerss[i]}\t{statusess[i]}\t{geos[i]}\t{coordinatess[i]}\t{places[i]}\n")