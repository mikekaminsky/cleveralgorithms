#particle_swarm_optimization.rb
#Michael Kaminsky

require 'json'

def objective_function(vector)
  return vector.inject(0.0) {|sum, x| sum + (x ** 2.0)}
end

def random_vector(minmax)
  return Array.new(minmax.size) do |i|
    minmax[i][0] + ((minmax[i][1] - minmax[i][0]) * rand())
  end
end

def create_particle(search_space, vel_space)
  particle = {}
  particle[:position] = random_vector(search_space)
  particle[:cost] = objective_function(particle[:position])
  particle[:b_position] = Array.new(particle[:position])
  particle[:b_cost] = particle[:cost]
  particle[:velocity] = random_vector(vel_space)
  return particle
end

def get_global_best(population, current_best=nil)
  best = population.sort{|left,right| left[:cost] <=> right[:cost]}.first
  if current_best.nil? or best[:cost] <= current_best[:cost]
    current_best = {}
    current_best[:position] = Array.new(best[:position])
    current_best[:cost] = best[:cost]
  end
  return current_best
end

def update_velocity(particle, gbest, max_v, c1, c2)
  particle[:velocity].each_with_index do |v,i|
    v1 = c1 * rand() * (particle[:b_position][i] - particle[:position][i])
    v2 = c2 * rand() * (gbest[:position][i] - particle[:position][i])
    particle[:velocity][i] = v + v1 + v2
    particle[:velocity][i] = max_v if particle[:velocity][i] > max_v
    particle[:velocity][i] = -max_v if particle[:velocity][i] < -max_v
  end
end

def update_position(part, bounds)
  part[:position].each_with_index do |v,i|
    part[:position][i] = v + part[:velocity][i]
    if part[:position][i] > bounds[i][1]
      part[:position][i]=bounds[i][1]-(part[:position][i]-bounds[i][1]).abs
      part[:velocity][i] *= -1.0
    elsif part[:position][i] < bounds[i][0]
      part[:position][i]=bounds[i][0]+(part[:position][i]-bounds[i][0]).abs
      part[:velocity][i] *= -1.0
    end
  end
end

def update_best_position(particle)
  return if particle[:cost] > particle[:b_cost]
  particle[:b_cost] = particle[:cost]
  particle[:b_position] = Array.new(particle[:position])
end

def get_locations(pop)
  locations = []
  pop.each do |particle|
    locations << {:x => particle[:position][0], :y => particle[:position][1]}
  end
  return locations
end

def search(max_gens, search_space, vel_space, pop_size, max_vel, c1, c2)
  pop = Array.new(pop_size) {create_particle(search_space, vel_space)}
  locations = get_locations(pop)
  data = []
  gendata = {:iteration => 0, :locations => locations}
  data << gendata
  gbest = get_global_best(pop)
  max_gens.times do |gen|
    pop.each do |particle|
      update_velocity(particle, gbest, max_vel, c1, c2)
      update_position(particle, search_space)
      particle[:cost] = objective_function(particle[:position])
      update_best_position(particle)
    end
    gbest = get_global_best(pop, gbest)
    locations = get_locations(pop)
    gendata = {:iteration => gen, :locations => locations}
    data << gendata
    puts " > gen #{gen+1}, fitness=#{gbest[:cost]}, position=#{gbest[:position]}"
  end
  return gbest, data
end

data = {}
problem_size = 2 # Number of dimensions
max_gens = 100 # Number of iterations
pop_size = 10 # Number of particles

search_space = Array.new(problem_size) {|i| [-5, 5]} # Size of field to search
vel_space = Array.new(problem_size) {|i| [-1, 1]} # ????
c1, c2 = 2.0, 2.0 # ???

# Original value: 100
# Changing to 10 leads all of the particles to get trapped in the corners
# Changing to 1 leads to more expected behavior
max_vel = 1.0

best, outdata = search(max_gens, search_space, vel_space, pop_size, max_vel, c1, c2)
puts "done! Solution: f=#{best[:cost]}, s=#{best[:position].inspect}"

metadata = {:problem_size => problem_size, 
            :spacemin => search_space.min.min,
            :spacemax => search_space.max.max,
            :solution => {:x => 0, :y => 0},
            :iterations => max_gens-1
          }

data = {:metadata => metadata, :data => outdata}
jsondata = data.to_json

# Write JSON data
path = 'visualizer/swarmdata.js'
begin
  file = File.open(path, "w")
  file.write('var JSONData =' + jsondata) 
rescue IOError => e
  #some error occur, dir not writable etc.
ensure
  file.close unless file == nil
end
