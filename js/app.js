const SET = 0;

const app = new Vue({
    el: '#app',
    data: {
        hello: 'Hello Vue!',
        items: [{
            slot: 0,
            type: 0,
            bonus: 0
        }, {
            slot: 1,
            type: 1,
            bonus: 1
        }],
        equipped: []
    }, 
    methods: {
        getPower: (type, bonus) => {
            return type + 1 + bonus;
        },
        getName: (slot, type, bonus) => {
            const bonusText = (bonus > 0) ? (' +' + bonus) : '';
            return LOOT.sets[SET].slots[slot][type].name + bonusText;
        },
        getDescription: (slot, type) => {
            return LOOT.sets[SET].slots[slot][type].description;
        },
        equip: function (item) {
            this.equipped[item.slot] = item;
        }
    }
})