/**
 * Enhanced Browser Detection JS
 */
shinybrowser = (function () {
  const UNKNOWN = "UNKNOWN";

  const isMobile = function () {
    return /Mobi/i.test(navigator.userAgent);
  };

  const getBrowser = function () {
    let browser = UNKNOWN;
    let version = UNKNOWN;
    const ua = navigator.userAgent;

    try {
      // Opera 15+
      if (ua.includes("OPR/")) {
        browser = "Opera";
        version = ua.match(/OPR\/(\d+)/i)[1];
      }
      // Firefox 1+
      else if (typeof InstallTrigger !== "undefined") {
        browser = "Firefox";
        version = ua.match(/firefox\/(\d+)/i)[1];
      }
      // Safari 3+
      else if (
        /constructor/i.test(window.HTMLElement) ||
        (typeof window.safari !== "undefined" &&
          typeof window.safari.pushNotification !== "undefined")
      ) {
        browser = "Safari";
        version = ua.match(/version\/(\d+)/i)[1];
      }
      // Internet Explorer 6-11
      else if (/* @cc_on!@*/ false || document.documentMode) {
        browser = "Internet Explorer";
        const msie = ua.indexOf("MSIE ");
        if (msie >= 0) {
          version = parseInt(ua.substring(msie + 5, ua.indexOf(".", msie)), 10);
        } else if (ua.match(/Trident.*rv\:11\./)) {
          version = "11";
        }
      }
      // Edge 20+
      else if (!document.documentMode && window.StyleMedia) {
        browser = "Edge";
        const edge = ua.indexOf("Edge/");
        if (edge >= 0) {
          version = parseInt(ua.substring(edge + 5, ua.indexOf(".", edge)), 10);
        }
      }
      // Edge Chromium
      else if (window.chrome && ua.includes("Edg")) {
        browser = "Edge";
        version = ua.match(/Chrom(e|ium)\/(\d+)/i)[2];
      }
      // Chrome
      else if (window.chrome) {
        browser = "Chrome";
        version = ua.match(/Chrom(e|ium)\/(\d+)/i)[2];
      }
      // Chrome on iOS
      else if (ua.includes("CriOS/")) {
        browser = "Chrome";
        version = ua.match(/CriOS\/(\d+)/i)[1];
      }
    } catch (err) {
      console.error("Error detecting browser: ", err);
    }

    return { name: browser, version: version };
  };

  const getOS = function () {
    let os = UNKNOWN;
    let version = UNKNOWN;
    const ua = navigator.userAgent;

    try {
      if (isMobile()) {
        if (/Windows/.test(ua)) {
          os = "Windows Phone";
          version = /Phone 10.0/.test(ua) ? 10 : 8;
        } else if (/android/i.test(ua)) {
          os = "Android";
          version = parseInt(ua.match(/android\s([0-9\.]*)/i)[1]);
        } else if (/iphone;/i.test(ua) || /ipad;/i.test(ua)) {
          os = "iOS";
          version = parseInt(
            navigator.appVersion.match(/OS (\d+)_(\d+)_?(\d+)?/)[1]
          );
        } else if (/BBd*/.test(ua)) {
          os = "BlackBerry";
        }
      } else {
        if (/Windows/.test(ua)) {
          os = "Windows";
          if (/NT 10.0/.test(ua)) version = "10";
          else if (/NT 6.2/.test(ua)) version = "8";
          else if (/NT 6.1/.test(ua)) version = "7";
          else if (/NT 6.0/.test(ua)) version = "Vista";
          else if (/NT 5.1/.test(ua)) version = "XP";
        } else if (/Mac/.test(ua)) {
          os = "Mac";
          if (/OS X/.test(ua)) version = "OS X";
        } else if (/Linux|X11/.test(ua)) {
          os = "Linux";
        }
      }
    } catch (err) {
      console.error("Error detecting OS: ", err);
    }

    return { name: os, version: version };
  };

  const detect = function () {
    const props = {
      device: isMobile() ? "Mobile" : "Desktop",
      browser: getBrowser(),
      os: getOS(),
      dimensions: {
        width: window.innerWidth,
        height: window.innerHeight,
      },
      user_agent: navigator.userAgent,
    };
    Shiny.setInputValue(".shinybrowser", props);
  };

  const init = function () {
    // Ensure Shiny is loaded before detecting browser and OS
    if (
      typeof Shiny === "undefined" ||
      typeof Shiny.setInputValue === "undefined"
    ) {
      $(document).on("shiny:connected", function () {
        detect();
      });
    } else {
      detect();
    }
  };

  return {
    getBrowser,
    getOS,
    detect,
    init,
  };
})();

// Initialize browser detection on document ready
$(function () {
  shinybrowser.init();
});
