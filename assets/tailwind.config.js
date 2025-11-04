// See the Tailwind configuration guide for advanced usage
// https://tailwindcss.com/docs/configuration

const plugin = require("tailwindcss/plugin")
const fs = require("fs")
const path = require("path")

module.exports = {
  content: [
    "./js/**/*.js",
    "../lib/mydia_web.ex",
    "../lib/mydia_web/**/*.*ex"
  ],
  theme: {
    extend: {
      colors: {
        brand: "#FD4F00",
      },
      fontFamily: {
        sans: ['Inter', 'ui-sans-serif', 'system-ui', 'sans-serif'],
        mono: ['JetBrains Mono', 'Fira Code', 'monospace'],
      },
    },
  },
  plugins: [
    require("@tailwindcss/forms"),
    require("daisyui"),
    // Allows prefixing tailwind classes with LiveView classes to add rules
    // only when LiveView classes are applied, for example:
    //
    //     <div class="phx-click-loading:animate-spin">
    //
    plugin(({addVariant}) => addVariant("phx-click-loading", [".phx-click-loading&", ".phx-click-loading &"])),
    plugin(({addVariant}) => addVariant("phx-submit-loading", [".phx-submit-loading&", ".phx-submit-loading &"])),
    plugin(({addVariant}) => addVariant("phx-change-loading", [".phx-change-loading&", ".phx-change-loading &"])),

    // Embeds Heroicons (https://heroicons.com) into your app.css bundle
    // See your `CoreComponents.icon/1` for more information.
    //
    plugin(function({matchComponents, theme}) {
      let iconsDir = path.join(__dirname, "../deps/heroicons/optimized")
      let values = {}
      let icons = [
        ["", "/24/outline"],
        ["-solid", "/24/solid"],
        ["-mini", "/20/solid"],
        ["-micro", "/16/solid"]
      ]
      icons.forEach(([suffix, dir]) => {
        fs.readdirSync(path.join(iconsDir, dir)).forEach(file => {
          let name = path.basename(file, ".svg") + suffix
          values[name] = {name, fullPath: path.join(iconsDir, dir, file)}
        })
      })
      matchComponents({
        "hero": ({name, fullPath}) => {
          let content = fs.readFileSync(fullPath).toString().replace(/\r?\n|\r/g, "")
          let size = theme("spacing.6")
          if (name.endsWith("-mini")) {
            size = theme("spacing.5")
          } else if (name.endsWith("-micro")) {
            size = theme("spacing.4")
          }
          return {
            [`--hero-${name}`]: `url('data:image/svg+xml;utf8,${content}')`,
            "-webkit-mask": `var(--hero-${name})`,
            "mask": `var(--hero-${name})`,
            "mask-repeat": "no-repeat",
            "background-color": "currentColor",
            "vertical-align": "middle",
            "display": "inline-block",
            "width": size,
            "height": size
          }
        }
      }, {values})
    })
  ],
  daisyui: {
    themes: [
      {
        mydia: {
          // Primary: Used for main actions, links, active states
          "primary": "#3b82f6",      // Blue-500
          "primary-content": "#ffffff",

          // Secondary: Used for less prominent actions
          "secondary": "#8b5cf6",    // Violet-500
          "secondary-content": "#ffffff",

          // Accent: Used for highlights, notifications
          "accent": "#06b6d4",       // Cyan-500
          "accent-content": "#ffffff",

          // Neutral: Background colors, borders
          "neutral": "#1f2937",      // Gray-800
          "neutral-content": "#f9fafb", // Gray-50

          // Base colors (dark theme)
          "base-100": "#0f172a",     // Slate-900 (main bg)
          "base-200": "#1e293b",     // Slate-800 (card bg)
          "base-300": "#334155",     // Slate-700 (hover)
          "base-content": "#f1f5f9",  // Slate-100 (text)

          // Semantic colors
          "info": "#3b82f6",         // Blue
          "success": "#10b981",      // Green
          "warning": "#f59e0b",      // Amber
          "error": "#ef4444",        // Red
        },
      },
      "light",  // Default light theme
      "dark",   // Default dark theme
    ],
    // Use our custom theme by default
    darkTheme: "mydia",
    // Disable some unused components to reduce CSS size
    base: true,
    styled: true,
    utils: true,
    logs: true,
    rtl: false,
  },
}
