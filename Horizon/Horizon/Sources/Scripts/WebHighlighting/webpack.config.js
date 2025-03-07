const path = require("path");

module.exports = (env, argv) => {
  const isProduction = argv.mode === "production";

  return {
    entry: "./dist/main.js",
    module: {
      rules: [
        {
          test: /\.tsx?$/,
          use: "ts-loader",
          exclude: /node_modules/,
        },
      ],
    },
    resolve: {
      extensions: [".tsx", ".ts", ".js", ".html"],
    },
    output: {
      filename: "WebHighlighting.js",
      path: path.resolve(__dirname, "../../../Resources"),
    },
    optimization: {
      minimize: isProduction,
    },
    mode: isProduction ? "production" : "development",
  };
};
