#Idea:  We'll have a directed graph that looks like this

# (start) <=> node => (batch of 10 interconnected nodes requiring two steps to get through)
# <=> node => (Kevin Bacon)

#This will be used to simulate wikipedia

#Each node name not specified above will be "node1" through "node22"

class SimulatedWikipedia
  @@page_titles = ["start"] + (1..22).map { |num| "node#{num}" } + ["Kevin Bacon"]
  @@graph_matrix = [
    [0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
    [1, 0, ],
    [],
    [],
    [],
    [],
    [],
    [],
    [],
    [],
    [],
    [],
    [],
    [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
  ]
end