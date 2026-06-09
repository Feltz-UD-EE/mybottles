if Rails.env.development? || Rails.env.test?
  env_path = Rails.root.join(".env")

  if env_path.exist?
    env_path.each_line do |line|
      next if line.blank? || line.start_with?("#")

      key, value = line.strip.split("=", 2)
      ENV[key] ||= value if key.present? && value.present?
    end
  end
end
