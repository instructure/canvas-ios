require 'open3'
require 'shellwords'

class ImageAssertion

  MAX_ALLOWED_DIFF_VALUE  = 1.0
  DIFF_IMAGE_FOLDER_NAME  = 'screens_diff'

  def self.assert_image(test_output, ref_images_path, image_name, threshold)
    return false unless (test_output && ref_images_path && image_name)

    diff_images_path  = File.join(ref_images_path, DIFF_IMAGE_FOLDER_NAME)
    Dir.mkdir(diff_images_path) unless File.directory?(diff_images_path)

    image_file_name   = image_name + '.png'
    expected_path     = File.join(ref_images_path, image_file_name)
    diff_path         = File.join(diff_images_path, image_file_name)
    
    run_folder_name   = find_last_folder(test_output)
    received_path     = File.join(run_folder_name, image_file_name)
    
    print_status(create_status('started', "Asserting #{received_path}."))

    if !File.exists?(received_path)
      error = "No captured image file found at #{received_path}"
      print_status(create_status('failed', error))
      return false
    elsif !File.exists?(expected_path)
      error = "No reference image file found at #{expected_path}"
      print_status(create_status('failed', error))
      return false
    else
      result, exit_status = im_compare(expected_path, received_path, diff_path)
      if exit_status == 0
        return process_imagemagick_result(image_file_name, result, threshold)
      elsif exit_status == 1
        print_status(create_status('failed', "Images differ, check #{diff_images_path} for details. ImageMagick error: #{result}"))
      else
        print_status(create_status('failed', "ImageMagick comparison failed: #{result}"))
      end
    end
  end

private

  # Iterte through folders with name Run* and return with latests run number
  def self.find_last_folder(test_output)
    folder_mask = "#{test_output}/Run";
    run_folders = Dir.glob("#{folder_mask}*")

    return test_output unless run_folders.length > 0

    run_folders.sort do |x, y|
      y.gsub(folder_mask, '').to_i <=> x.gsub(folder_mask, '').to_i
    end[0]
  end

  def self.process_imagemagick_result(image_file_name, result, threshold)
    result_status   = 'failed'
    result_message  = "#{image_file_name} is not equal to the reference."
    assertionResult = false

    #imagemagick outputs floating point metrics value when succeeds
    compare_succeed = ( result.match(/[0-9]*\.?[0-9]+/).length > 0 )
    threshold ||= MAX_ALLOWED_DIFF_VALUE

    if compare_succeed
      if result.to_f < threshold

        result_status   = 'passed'
        result_message  = "#{image_file_name} asserted successfully."
        assertionResult = true
      else
        print_status(create_status(result_status, "expected diff is smaller than #{threshold} but #{result.to_f}."))
      end
    else

      result_message    = result
    end

    print_status(create_status(result_status, result_message))
    assertionResult
  end

  def self.create_status(status, message)
    "#{Time.new} #{status}: #{message}"
  end

  def self.print_status(message)
    $stderr.puts(message)
  end

  def self.im_compare(expected_path, received_path, diff_path)
    command = '/usr/local/bin/compare -metric MAE '
    command << Shellwords.escape(expected_path) + ' '
    command << Shellwords.escape(received_path) + ' '
    command << ( diff_path ? Shellwords.escape(diff_path) : 'null:' )

    _, _, stderr, wait_thr = Open3.popen3(command)
    [stderr.read, wait_thr.value.exitstatus]
  end
end
