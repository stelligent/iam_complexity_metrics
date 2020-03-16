import pandas
import json
import matplotlib.pyplot as pyplot

occurrences_files = [
  'occurrences.json',
  'occurrences2.json',
  'occurrences3.json'
]

for occurrences_file in occurrences_files:
  spodo_occurrences_json = open(occurrences_file, 'r').read()
  spodo_occurrences = json.loads(spodo_occurrences_json)

  data_frame = pandas.DataFrame(spodo_occurrences)
  data_frame.plot(
    kind='scatter',
    x='SPoDoCM',
    y='# Occurrences',
    logx=False,
    marker='.'
  )
  pyplot.show()

  pyplot.savefig(f'{occurrences_file}.png')
