require "couchrest"

module CouchRest::Mixins::DesignFiles

  def register_design(name, design)
    view = "_design/#{name}"
    doc  = find_or_initialize(view)
    doc  = doc.merge(design)
    save_doc(doc)
  end

  def update_designs(design_dir)
    designs = {}

    Dir.chdir(design_dir) do
      Dir["**/*.js"].each do |design_file|
        path  = design_file.split("/")
        file  = path.pop.gsub(".js", "")
        path.inject(designs) do |hash, chunk|
          hash[chunk] ||= {}
          hash[chunk]
        end[file] = File.read(design_file)
      end
    end

puts designs.inspect

    designs.each do |name, design|
      register_design name, design
    end
  end

end
