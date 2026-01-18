const params = new URLSearchParams(window.location.search);
const priceParam = params.get('price');


document.addEventListener('DOMContentLoaded', () => {
    const el = document.getElementById('pricenumberdata');
    if (el && priceParam !== null) {
        el.textContent = priceParam;
    }
});
