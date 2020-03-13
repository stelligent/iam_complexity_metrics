# frozen_string_literal: true
require 'rake'
require 'json'
require_relative 'lib/iam_complexity_metrics/cloudformation'
require_relative 'lib/iam_complexity_metrics/account'

desc 'Apply metrics to IAM resources in CloudFormation templates'
task :cfn_iam_metrics, :target_dir do |_, args|
  file_metrics = {}
  cfn_files = FileList[
    "#{args[:target_dir]}/**/*.json",
    "#{args[:target_dir]}/**/*.template",
    "#{args[:target_dir]}/**/*.yml",
    "#{args[:target_dir]}/**/*.yaml"
  ]
  cfn_files.each do |cfn_file|
    metrics = CloudFormation.new.iam_metrics IO.read(cfn_file)
    next if metrics == {}
    next if metrics == []
    file_metrics[cfn_file] = metrics
  end
  puts JSON.pretty_generate(file_metrics)
end

desc 'Apply metrics to live IAM resources in AWS account'
task :live_iam_metrics, :aws_profile do |_, args|
  metrics = Account.new(args[:aws_profile]).iam_metrics
  puts JSON.pretty_generate(metrics)
end
