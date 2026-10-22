module ApplicationHelper
  THEMES = { "system" => "Sistema", "light" => "Claro", "dark" => "Escuro" }.freeze

  # Set by the theme switch (theme_controller.js); read here so the first paint is already right.
  def theme_preference
    cookies[:theme].presence_in(THEMES.keys) || "system"
  end
end
