module ComponentLibrary2100
  # @logical_path feedback
  class PwaInstallPreview < BasePreview
    # The banner renders hidden and only shows when the browser offers to install, so this preview
    # has buttons that stand in for the browser: one fires a fake beforeinstallprompt, the other
    # shows the iOS guidance. A dismissal is remembered for `dismiss_days`; clear localStorage to
    # see it again.
    #
    # @param app_name text
    # @param install_label text
    # @param dismiss_days number
    def playground(app_name: "2100 Enterprises", install_label: "Install", dismiss_days: 0)
      template("playground", app_name: app_name, install_label: install_label, dismiss_days: dismiss_days.to_i)
    end
  end
end
