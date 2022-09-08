function updateStatus(state) {
    for (tag in state) {
        document.getElementById(tag + '.state').textContent = state[tag];

        fetch('/api/results/' + tag).then(response => {
            response.json().then(data => {
                for (const result of data) {
                    document.getElementById(result.tag + '.result.' + result.name).textContent = result.content;
                }
            });
        });
    }
}

function updateStatusUnknown() {
    const tags = ['local', 'pv'];

    for (const tag of tags) {
        document.getElementById(tag + '.state').textContent = "Unknown";
        document.getElementById(tag + '.result.run1').textContent = "no result";
        document.getElementById(tag + '.result.run2').textContent = "no result";
    }
}

function updateResults() {
    fetch('/api/state')
        .then(response => {
            if (response.ok) {
                response.json().then(updateStatus);
            } else {
                updateStatusUnknown();
            }
        });

    setTimeout(updateResults, 5000);
}

document.addEventListener('DOMContentLoaded',function(){
    updateResults();
});
