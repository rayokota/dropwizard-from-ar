require 'artii'

class TemplateProcessor

  private

  def self.adjust(s)
    s.gsub(/^\s+<%(.*).%>$/, "<%\\1%>")
  end

  def self.load_template(file_name)
    ERB.new(adjust(File.read(File.dirname(__FILE__) + "/" + file_name)), nil, "<>")
  end

  public

  def self.process(project_defn, output_dir, model_defns_by_namespace_table_names, migration_number)
    mkdirs(project_defn, output_dir)

    all_model_defns = []
    project_defn.databases.each do |database_defn|
      by_table_name = model_defns_by_namespace_table_names[database_defn.namespace]
      model_defns = by_table_name.values.sort_by{|x| x.table_name}
      all_model_defns += model_defns

      process_database_defn(project_defn, database_defn, output_dir, model_defns, by_table_name)
    end

    generate_all(project_defn, all_model_defns.sort_by{|x| x.table_name}, output_dir)

    puts "Found #{all_model_defns.size} models"
  end
  
  def self.process_database_defn(project_defn, database_defn, output_dir, model_defns, by_table_name)
=begin
    output_dir = output_dir.dup + "/" + database_defn.namespace.gsub(".", "/")

    db_name = database_defn.name
    root_package = database_defn.namespace
=end

    model_defns.each do |model_defn|
      generate_model(model_defn, project_defn, output_dir)
    end
  end

=begin
  def self.render_create_method(model_defn, signature, only_not_null = false)
    CREATE_METHOD_TEMPLATE.result(binding)
  end

  def self.render_mock_create_method(model_defn, signature, only_not_null = false)
    MOCK_CREATE_METHOD_TEMPLATE.result(binding)
  end
=end

  def self.mkdirs(project_defn, output_dir)
    service_name = project_defn.service_name
    FileUtils.mkdir_p "#{output_dir}/#{service_name}/#{service_name}-api"
    FileUtils.mkdir_p "#{output_dir}/#{service_name}/#{service_name}-client/src/main/java/com/yammer/#{service_name}/client"
    FileUtils.mkdir_p "#{output_dir}/#{service_name}/#{service_name}-service/src/main/java/com/yammer/#{service_name}/service"
    FileUtils.mkdir_p "#{output_dir}/#{service_name}/#{service_name}-service/src/main/java/com/yammer/#{service_name}/service/dao"
    FileUtils.mkdir_p "#{output_dir}/#{service_name}/#{service_name}-service/src/main/java/com/yammer/#{service_name}/service/model"
    FileUtils.mkdir_p "#{output_dir}/#{service_name}/#{service_name}-service/src/main/java/com/yammer/#{service_name}/service/resources"
    FileUtils.mkdir_p "#{output_dir}/#{service_name}/#{service_name}-service/src/main/java/com/yammer/#{service_name}/service/views"
    FileUtils.mkdir_p "#{output_dir}/#{service_name}/#{service_name}-service/src/main/resources"
    FileUtils.mkdir_p "#{output_dir}/#{service_name}/#{service_name}-service/src/main/resources/assets/css"
    FileUtils.mkdir_p "#{output_dir}/#{service_name}/#{service_name}-service/src/main/resources/assets/img"
    FileUtils.mkdir_p "#{output_dir}/#{service_name}/#{service_name}-service/src/main/resources/assets/js"
  end

  def self.generate_all(project_defn, model_defns, output_dir)
    service_name = project_defn.service_name
    a = Artii::Base.new
    banner = a.asciify(service_name)

    files = {
        "findbugs-exclude.xml.erb"         => "findbugs-exclude.xml",
        "parent-pom.xml.erb"               => "pom.xml",
        "README.md.erb"                    => "README.md",
        "api-pom.xml.erb"                  => "#{service_name}-api/pom.xml",
        "client-pom.xml.erb"               => "#{service_name}-client/pom.xml",
        "DropwizardClient.java.erb"        => "#{service_name}-client/src/main/java/com/yammer/#{service_name}/client/#{service_name.cap_first}Client.java",
        "service-pom.xml.erb"              => "#{service_name}-service/pom.xml",
        "dropwizard.yml.erb"               => "#{service_name}-service/#{service_name}.yml",
        "DropwizardConfiguration.java.erb" => "#{service_name}-service/src/main/java/com/yammer/#{service_name}/service/#{service_name.cap_first}Configuration.java",
        "DropwizardResource.java.erb"      => "#{service_name}-service/src/main/java/com/yammer/#{service_name}/service/resources/#{service_name.cap_first}Resource.java",
        "DropwizardService.java.erb"       => "#{service_name}-service/src/main/java/com/yammer/#{service_name}/service/#{service_name.cap_first}Service.java",
        "banner.txt.erb"                   => "#{service_name}-service/src/main/resources/banner.txt",

        "IndexView.java.erb"               => "#{service_name}-service/src/main/java/com/yammer/#{service_name}/service/views/IndexView.java",
        "index.ftl.erb"                    => "#{service_name}-service/src/main/resources/com/yammer/#{service_name}/service/views/index.ftl",
        "bootstrap.min.css"                => "#{service_name}-service/src/main/resources/assets/css/bootstrap.min.css",
        "datepicker.css"                   => "#{service_name}-service/src/main/resources/assets/css/datepicker.css",
        "glyphicons-halflings.png"         => "#{service_name}-service/src/main/resources/assets/img/glyphicons-halflings.png",
        "glyphicons-halflings-white.png"   => "#{service_name}-service/src/main/resources/assets/img/glyphicons-halflings-white.png",
        "bootstrap.min.js"                 => "#{service_name}-service/src/main/resources/assets/js/bootstrap.min.js",
        "bootstrap-datepicker.js"          => "#{service_name}-service/src/main/resources/assets/js/bootstrap-datepicker.js",
        "jquery-1.7.2.min.js"              => "#{service_name}-service/src/main/resources/assets/js/jquery-1.7.2.min.js",
        "header.ftl.erb"                   => "#{service_name}-service/src/main/resources/com/yammer/#{service_name}/service/views/header.ftl",
        "footer.ftl.erb"                   => "#{service_name}-service/src/main/resources/com/yammer/#{service_name}/service/views/footer.ftl",
    }
    files.each { |key, value| generate(nil, project_defn, output_dir, binding, key, value) }
  end

  def self.generate_model(model_defn, project_defn, output_dir)
    service_name = project_defn.service_name
    model = model_defn.model_name.down_first
    model_plural = model.pluralize
    attrs = model_defn.attrs

    create_signature_full = model_defn.fields.map{|field_defn| ["final", field_defn.java_type, field_defn.name].join(" ")}.join(", ")
    create_signature_small = model_defn.fields.reject{|field_defn| field_defn.nullable? }.map{|field_defn| ["final", field_defn.java_type, field_defn.name].join(" ")}.join(", ")
    create_signature_small = create_signature_full == create_signature_small || create_signature_small.empty? ? nil : create_signature_small

    FileUtils.mkdir_p "#{output_dir}/#{service_name}/#{service_name}-service/src/main/resources/com/yammer/#{service_name}/service/views/#{model_plural}"

    files = {
        "HibernateDAO.java.erb"       => "#{service_name}-service/src/main/java/com/yammer/#{service_name}/service/dao/#{model_defn.model_name.cap_first}DAO.java",
        "HibernateIndexView.java.erb" => "#{service_name}-service/src/main/java/com/yammer/#{service_name}/service/views/#{model_defn.model_name.cap_first}IndexView.java",
        "HibernateModel.java.erb"     => "#{service_name}-service/src/main/java/com/yammer/#{service_name}/service/model/#{model_defn.model_name.cap_first}.java",
        "HibernateResource.java.erb"  => "#{service_name}-service/src/main/java/com/yammer/#{service_name}/service/resources/#{model_defn.model_name.cap_first}Resource.java",
        "HibernateShowView.java.erb"  => "#{service_name}-service/src/main/java/com/yammer/#{service_name}/service/views/#{model_defn.model_name.cap_first}ShowView.java",
        "hibernate-index.ftl.erb"     => "#{service_name}-service/src/main/resources/com/yammer/#{service_name}/service/views/#{model_plural}/index.ftl",
        "hibernate-show.ftl.erb"      => "#{service_name}-service/src/main/resources/com/yammer/#{service_name}/service/views/#{model_plural}/show.ftl",
    }
    files.each { |key, value| generate(model_defn, project_defn, output_dir, binding, key, value) }
  end

  def self.generate(model_defn, project_defn, output_dir, binding, source, target)
    service_name = project_defn.service_name

    puts "Generating #{target}..."
    file = File.new("#{output_dir}/#{service_name}/#{target}", "w")
    file.puts(load_template("templates/#{source}").result(binding))
    file.close
  end

end
