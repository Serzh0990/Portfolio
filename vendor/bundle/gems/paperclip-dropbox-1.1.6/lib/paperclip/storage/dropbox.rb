require "dropbox_sdk"
require "active_support/core_ext/hash/keys"
require "paperclip/storage/dropbox/path_generator"
require "paperclip/storage/dropbox/url_generator"
require "paperclip/storage/dropbox/credentials"

module Paperclip
  module Storage
    module Dropbox
      def self.extended(base)
        base.instance_eval do
          @options[:dropbox_options] ||= {}
          @options[:dropbox_credentials] = fetch_credentials
          @options[:path] = nil if @options[:path] == self.class.default_options[:path]
          @path_generator = PathGenerator.new(self, @options)
          @url_generator = UrlGenerator.new(self, @options)
        end
      end

      def flush_writes
        @queued_for_write.each do |style, file|
          dropbox_client.put_file(path(style), file.read)
        end
        after_flush_writes
        @queued_for_write.clear
      end

      def flush_deletes
        @queued_for_delete.each do |path|
          dropbox_client.file_delete(path)
        end
        @queued_for_delete.clear
      end

      def url(style_or_options = default_style, options = {})
        options.merge!(style_or_options) if style_or_options.is_a?(Hash)
        style = style_or_options.is_a?(Hash) ? default_style : style_or_options
        @url_generator.generate(style, options)
      end

      def path(style = default_style)
        @path_generator.generate(style)
      end

      def copy_to_local_file(style = default_style, destination_path)
        File.open(destination_path, "wb") do |file|
          file.write(dropbox_client.get_file(path(style)))
        end
      end

      def exists?(style = default_style)
        return false if not present?
        metadata = dropbox_client.metadata(path(style))
        not metadata.nil? and not metadata["is_deleted"]
      rescue DropboxError
        false
      end

      def dropbox_client
        @dropbox_client ||= begin
          credentials = @options[:dropbox_credentials]
          session = DropboxSession.new(credentials[:app_key], credentials[:app_secret])
          session.set_access_token(credentials[:access_token], credentials[:access_token_secret])
          DropboxClient.new(session, credentials[:access_type] || "dropbox")
        end
      end

      def app_folder?;   @options[:dropbox_credentials][:access_type] == "app_folder"; end
      def full_dropbox?; @options[:dropbox_credentials][:access_type] == "dropbox";    end

      private

      def fetch_credentials
        environment = defined?(Rails) ? Rails.env : @options[:dropbox_options][:environment]
        Credentials.new(@options[:dropbox_credentials]).fetch(environment)
      end

      class FileExists < RuntimeError
      end
    end
  end
end
