(() => {
    const channel = new BroadcastChannel('flutter_beacon_bridge');

    channel.onmessage = (ev) => {
        try {
            console.log('Beacon message received: ', ev);
            const data = JSON.parse(ev.data);

            console.log('Parsed Beacon message: ', data);
            switch (data.type) {
                case 'init':
                    window.Beacon('init', data.payload.beaconId);
                    break;
                case 'config':
                    break;
                case 'identify':
                    window.Beacon('identify', data.payload.userObject);
                    break;
                case 'open':
                    window.Beacon('open');
                    break;
                case 'close':
                    window.Beacon('close');
                    break;
                case 'toggle':
                    break;
                case 'search':
                    break;
                case 'suggest':
                    break;
                case 'article':
                    window.Beacon('article', data.payload.article);
                    break;
                case 'navigate':
                    break;
                case 'prefill':
                    break;
                case 'reset':
                    break;
                case 'logout':
                    break;
                case 'destroy':
                    window.Beacon('destroy');
                    break;
            }
        } catch (e) {
            console.error(e);
        }
    }
})();