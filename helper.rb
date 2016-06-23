module Helper

  def self.create_new_suffix
    current_max = Dir["results/*"].
      select { |e| e =~ /out/ }.                             # Get only the files in this dir that match our data output file format
      tap    { |e| puts e }.
      map    { |e| e.split(/out|\.json/).last.to_i}.max || 0 # From this set, get the maximum suffix

    new_max = current_max + 1

    raise "\nMAX SUFFIX REACHED: #{new_max}" if new_max > 99

    new_max < 10 ? "0#{new_max}" : new_max.to_s
  end

end
