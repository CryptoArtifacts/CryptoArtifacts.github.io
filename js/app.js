const app = new Vue({
    el: '#app',
    data: {
        hello: 'Hello Vue!',
        items: [{
            data: LOOT[22 - 1],
            img: 22
        }, {
            data: LOOT[26 - 1],
            img: 26
        }],
    }
})