const App = Vue.createApp({
  data() {
    return {
      visible: false,

      search: '',
      players: [],
      currentPlayer: false,
    };
  },
  computed: {
    filteredPlayers() {
      if (this.search === '') return this.players;

      return this.players.filter((player) => {
        if (!isNaN(parseInt(this.search))) return player.id === parseInt(this.search);
        else return player.name.toLowerCase().includes(this.search.toLowerCase());
      });
    },
  },
  methods: {
    close() {
      fetch(`https://${GetParentResourceName()}/close`);
    },
    update() {
      fetch(`https://${GetParentResourceName()}/update`);
    },
    off() {
      fetch(`https://${GetParentResourceName()}/spectateoff`);
    },
    spectate(player) {
      fetch(`https://${GetParentResourceName()}/spectate`, {
        method: 'POST',
        body: JSON.stringify({
          player,
        }),
      });
    },
    async kick(player) {
      const { value: reason } = await Swal.fire({
        title: 'Enter kick reason',
        input: 'text',
        showCancelButton: true,
        inputValidator: (value) => {
          if (!value) {
            return 'You need to write something!';
          }
        },
      });

      if (!reason) return;

      fetch(`https://${GetParentResourceName()}/kick`, {
        method: 'POST',
        body: JSON.stringify({
          player,
          reason,
        }),
      });
    },
    async setjob(player) { /** */
      const { value: job, value2: grade} = await Swal.fire({
        title: 'Enter a job',
        input: 'text',
        showCancelButton: true,
        inputValidator: (value, value2) => {
          if (!value) {
            return 'You need to write something!';
          } else if (!value2) {
            return 'asdsad';
          }
        },

      });
      if (!job, !grade) return;

      fetch(`https://${GetParentResourceName()}/setjobplayer`, {
        method: 'POST',
        body: JSON.stringify({
          player,
          job,
          grade,
        }),
      });
    },
  },
  
  mounted() {
    window.addEventListener('message', ({ data }) => {
      if (data.visible !== undefined) this.visible = data.visible;
      if (data.players !== undefined) this.players = data.players;
      if (data.playerInfo !== undefined) this.currentPlayer = data.playerInfo;
    });
  },
}).mount('#app');

const playerInfoElement = document.querySelector('#playerinfo #data');
window.addEventListener('message', ({ data }) => {
  if (data.playerInfo !== undefined) {
    if (!data.playerInfo) {
      playerInfoElement.style.display = 'none';
      return;
    }
    playerInfoElement.style.display = 'block';
    playerInfoElement.innerHTML = data.playerInfo.join('<br>');
  }
});
