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

desc 'Generate statistics for AWS managed policies'
task :stats, :aws_profile do |_, args|
  metrics = Account.new(args[:aws_profile]).iam_metrics
  stats = {}
  total_complexity = metrics.values.reduce(0) { |sum, spodo|  sum + spodo }
  stats[:median] = total_complexity / metrics.values.size
  stats[:max] = metrics.values.max
  stats[:min] = metrics.values.min

  occurences_hash = {}
  metrics.values.each do |spodo|
    if occurences_hash.has_key? spodo
      occurences_hash[spodo] += 1
    else
      occurences_hash[spodo] = 1
    end
  end
  mode = 0
  highest_count = 0
  occurences_hash.each do |spodo, count|
    if count > highest_count
      mode = spodo
      highest_count = count
    end
  end
  stats[:mode] = mode
  stats[:occurences_of_one_to_five] = (1..5).reduce(0) { |sum, spodo| sum + occurences_hash[spodo] }
  stats[:occurences_of_one_to_twenty] = (1..20).reduce(0) { |sum, spodo| sum + occurences_hash[spodo] }
  stats[:total_complexity] = total_complexity
  puts stats

  occurences_hash2 = {'SPCM'=>occurences_hash.keys.map {|x| x.to_i }, '# Occurrences'=>occurences_hash.values}
  File.open('occurrences.json', 'w') { |file| file.write(JSON.pretty_generate(occurences_hash2)) }

  occurences_hash3 = {'SPCM'=>[], '# Occurrences'=>[]}
  occurences_hash.each do |k,v|
    if k.to_i < 25
      occurences_hash3['SPCM'] << k
      occurences_hash3['# Occurrences'] << v
    end
  end
  File.open('occurrences2.json', 'w') { |file| file.write(JSON.pretty_generate(occurences_hash3)) }

  occurences_hash4 = {'SPCM'=>[], '# Occurrences'=>[]}
  occurences_hash.each do |k,v|
    if k.to_i < 50
      occurences_hash4['SPCM'] << k
      occurences_hash4['# Occurrences'] << v
    end
  end
  File.open('occurrences3.json', 'w') { |file| file.write(JSON.pretty_generate(occurences_hash4)) }
end
