
/**
 * @example
 *
 * // show browser loading UI for 1.5s
 * showLoading(new Promise(r => setTimeout(r, 1500)));
*/
function showLoadingTitle(promise) {
  navigation.addEventListener('navigate', evt => {
    evt.intercept({
      scroll: 'manual',
      handler: () => promise,
    });
  }, { once: true });
  return navigation.navigate(location.href).finished;
}
