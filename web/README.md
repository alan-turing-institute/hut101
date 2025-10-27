Serve locally:

```
pnpm dev
```

Build:

```
pnpm build
```

The content is currently stored as Markdown inside `src/pages`. You should only really need to edit those.

If you add a new page, make sure to also add it to the sidebar in `src/Navigation.astro`.
You will need to copy the Markdown frontmatter from another page to get started (to make sure that it is rendered using the correct layout).
The filename will determine the URL pathname: `src/pages/foo.md` corresponds to `/foo`.

You can put HTML inside the Markdown too, if you want to have more control over what appears.
I'm fairly sure it allows completely arbitrary HTML, at least, I inserted a `<script type="text/javascript">` and it worked.
