module Tumbler
  class RakeTasks

    def self.register(base, name)
      if manager = Tumbler.load(base)
        tasks = RakeTasks.new(manager)
        tasks.activate_project_tasks(name)
      else
        raise "This is not properly configured for tumbler probably due to a lack of a Tumbler configuration file."
      end
    end

    def initialize(manager)
      @manager = manager
    end

    def activate_project_tasks(protect_namespace)
      tasks = proc do
        namespace :tumbler do
          task :preflight do
          end
        end

        namespace :gem do
          desc "Build the gem"
          task :build => 'tumbler:preflight' do
            @manager.gem.build
          end

          desc "Push the gem"
          task :push => 'tumbler:preflight' do
            @manager.gem.push
          end

          desc "Install the gem"
          task :install => 'tumbler:preflight' do
            @manager.gem.install
          end
        end

        namespace :version do
          desc "Tag current version into git"
          task :tag => 'tumbler:preflight' do
            @manager.tag
          end
        
          desc "Push current version into git"
          task :push => 'tumbler:preflight' do
            @manager.tag_and_push
          end
        
          @manager.version.field_names.each do |field|
            namespace field do 
              desc "Bump version from #{@manager.version.to_s} ->  #{@manager.version.value.bump(field).to_s}"
              task :bump => 'tumbler:preflight' do
                @manager.bump_and_commit(field)
              end

              task :push => 'tumbler:preflight' do
                @manager.tag_and_push(field)
              end

              desc "Bump version from #{@manager.version.to_s} ->  #{@manager.version.value.bump(field).to_s} and push"
              task :release => 'tumbler:preflight' do
                @manager.bump_and_push(field)
              end
            end
          end
        end
      end

      if protect_namespace
        namespace protect_namespace, &tasks
      else
        tasks.call
      end
    end
  end
end