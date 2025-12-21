import ApexCharts from "apexcharts";

let Hooks = {};

Hooks.BarChart = {
  mounted() {
    this.theme = this.getCurrentTheme();
    this.data = { series: [], bounds: [] };
    this.initChart();
    this.handleEvent("update_chart", ({ data }) => this.updateChart(data));

    window.addEventListener("phx:theme:changed", (e) => {
      this.theme = e.detail.theme;
      this.destroyChart();
      this.initChart();
    });
  },

  getCurrentTheme() {
    return document.documentElement.getAttribute("data-theme") || "light";
  },

  initChart() {
    const data = JSON.parse(this.el.dataset.chartData);

    this.chart = new ApexCharts(this.el, {
      dataLabels: { enabled: false },
      chart: {
        background: "transparent",
        type: "bar",
        height: 350,
        stacked: true,
        toolbar: { show: false },
        events: {
          dataPointSelection: (event, chartContext, config) => {
            // const label = data.categories[config.dataPointIndex];
            // const seriesName = config.w.config.series[config.seriesIndex].name;
            // const index =
            //   config.w.config.series[config.seriesIndex].data[
            //     config.dataPointIndex
            //   ];

            const classifications = this.data.series[config.seriesIndex].deps;
            const bounds = this.data.bounds[config.dataPointIndex];

            this.pushEvent("filter", {
              classifications,
              date_from: bounds[0],
              date_to: bounds[1],
            });
          },
          legendClick: (chartContext, seriesIndex, { config }) => {
            console.log(config);
            const classifications = this.data.series[seriesIndex].deps;
            this.pushEvent("filter", {
              classifications,
            });
          },
        },
      },
      theme: {
        mode: this.theme === "dark" ? "dark" : "light",
      },
      series: data.series,
      xaxis: {
        categories: data.categories,
        labels: {
          style: { colors: this.theme === "dark" ? "#e5e7eb" : "#374151" },
        },
      },
      yaxis: {
        labels: {
          style: { colors: this.theme === "dark" ? "#e5e7eb" : "#374151" },
        },
      },
      legend: {
        labels: { colors: this.theme === "dark" ? "#e5e7eb" : "#374151" },
        fontFamily: "Archivo, sans-serif",
        fontWeight: 600,
        onItemClick: {
          toggleDataSeries: false,
        },
        onItemHover: {
          highlightDataSeries: false,
        },
      },
      colors: data.colors,
    });

    this.data = data;
    this.chart.render();
  },

  updateChart(newData) {
    this.data = newData;
    this.chart.updateOptions({
      series: newData.series,
      xaxis: { categories: newData.categories },
      colors: newData.colors,
    });
  },

  destroyChart() {
    this.chart.destroy();
  },
};

// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//
// If you have dependencies that try to import CSS, esbuild will generate a separate `app.css` file.
// To load it, simply add a second `<link>` to your `root.html.heex` file.

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html";
// Establish Phoenix Socket and LiveView configuration.
import { Socket } from "phoenix";
import { LiveSocket } from "phoenix_live_view";
import topbar from "../vendor/topbar";

const csrfToken = document
  .querySelector("meta[name='csrf-token']")
  .getAttribute("content");

// Show progress bar on live navigation and form submits
topbar.config({ barColors: { 0: "#29d" }, shadowColor: "rgba(0, 0, 0, .3)" });
window.addEventListener("phx:page-loading-start", (_info) => topbar.show(300));
window.addEventListener("phx:page-loading-stop", (_info) => topbar.hide());

const liveSocket = new LiveSocket("/live", Socket, {
  longPollFallbackMs: 2500,
  params: { _csrf_token: csrfToken },
  hooks: Hooks,
});

// connect if there are any LiveViews on the page
liveSocket.connect();

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket;

// The lines below enable quality of life phoenix_live_reload
// development features:
//
//     1. stream server logs to the browser console
//     2. click on elements to jump to their definitions in your code editor
//
if (process.env.NODE_ENV === "development") {
  window.addEventListener(
    "phx:live_reload:attached",
    ({ detail: reloader }) => {
      // Enable server log streaming to client.
      // Disable with reloader.disableServerLogs()
      reloader.enableServerLogs();

      // Open configured PLUG_EDITOR at file:line of the clicked element's HEEx component
      //
      //   * click with "c" key pressed to open at caller location
      //   * click with "d" key pressed to open at function component definition location
      let keyDown;
      window.addEventListener("keydown", (e) => (keyDown = e.key));
      window.addEventListener("keyup", (e) => (keyDown = null));
      window.addEventListener(
        "click",
        (e) => {
          if (keyDown === "c") {
            e.preventDefault();
            e.stopImmediatePropagation();
            reloader.openEditorAtCaller(e.target);
          } else if (keyDown === "d") {
            e.preventDefault();
            e.stopImmediatePropagation();
            reloader.openEditorAtDef(e.target);
          }
        },
        true
      );

      window.liveReloader = reloader;
    }
  );
}
