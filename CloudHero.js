const httpGet = (url) => {
    return fetch(url).then(response => {
        if (response.status !== 200) {
            console.log('Looks like there was a problem. Status Code: ' + response.status);
            return;
        }

        return response.json();
    });
}

const initGameId = async () => {
    const frags = window.location.href.split('/');
    labId = frags[frags.length-1] ? frags[frags.length-1] : null;

    if (!labId || isNaN(labId)) {
        labId = window.labId;
    }

    if (!labId || isNaN(labId)) {
        console.log('Invalid Lab ID')
        return;
    }

    const gameData = await httpGet(
        `https://www.cloudskillsboost.google/focuses/show_spl/${labId}.json?parent=game`);

    if (!gameData) {
        return;
    }
    return gameData.labInstanceId;
}


const runTests = async (gameId) => {
    const testIds = window.testIds;
    if (!testIds || !Array.isArray(testIds) || testIds.length == 0) {
        console.log(`No tests in list.`)
        return;
    }

    const testId = testIds[0];
    console.log(`Checking test #${testId}...`)
    const stepUrl = `https://www.cloudskillsboost.google/assessments/run_step.json?id=${gameId}&step=${testId}`;
    stepResponse = await httpGet(stepUrl);
    if (!stepResponse) {
        console.log(`Test failed.`);
        return;
    }

    const testResults = stepResponse.step_complete;
    if (!testResults || !Array.isArray(testResults)) {
        console.log(`Invalid test results.`);
        return;
    }

    if (testResults.every(r => r)) {
        console.log(`Finishing lab.`);
        httpGet(`https://www.cloudskillsboost.google/lab_instances/end/${gameId}.json`);
        return;
    }

    if (testResults[testId - 1]) {
        window.testIds.splice(0, 1);
        console.log(`Test ${testId} done. Removing from list and running next.`);
        runTests(gameId);
    } else {
        setTimeout(() => runTests(gameId), 
            !isNaN(window.testTimeout) ? window.testTimeout : 3000);
    }
}

initGameId().then(gameId => {
    if (!gameId) {
        console.log('Invalid GameId')
        return;
    }
    runTests(gameId);
});
