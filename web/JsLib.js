function getUA() {
    return navigator.userAgent;
}

function isPwaInstalled() {
    return window.matchMedia('(display-mode: standalone)').matches;
}