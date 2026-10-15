/// Host of the links the app opens (app links / universal links).
const _appLinkHost = 'https://recipe-ai-5e261.web.app';

/// Path of the screen to join a list with the invitation [token].
String shoppingListJoinPath(String token) => '/shopping-lists/join/$token';

/// Link sent to invite someone to a shopping list.
String shoppingListInviteUrl(String token) =>
    '$_appLinkHost${shoppingListJoinPath(token)}';
