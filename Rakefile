# frozen_string_literal: true
require 'rake'
require_relative 'lib/iam_complexity_metrics/cloudformation'

desc 'Apply metrics to all IAM resources in CloudFormation templates'
task :iam_metrics, :target_dir do |task, args|
  file_metrics = {}
  cfn_files = FileList[
    "#{args[:target_dir]}/**/*.json",
    "#{args[:target_dir]}/**/*.yml",
    "#{args[:target_dir]}/**/*.yaml"
  ]
  cfn_files.each do |cfn_file|
    metrics = CloudFormation.new.iam_metrics IO.read(cfn_file)

    file_metrics[cfn_file] = metrics
  end
  puts file_metrics
end

