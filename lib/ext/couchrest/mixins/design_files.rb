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
        design, design_type, name, algorithm_type = design_file.gsub(/\.js$/, "").split("/")
        designs[design] ||= {}
        designs[design][design_type] ||= {}
        designs[design][design_type][name] ||= {}
        designs[design][design_type][name][algorithm_type] = File.read(design_file)
      end
    end

    designs.each do |name, design|
      register_design name, design
    end
  end

end
