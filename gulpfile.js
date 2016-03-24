// TODO: gulp-rsync triggered from watches instead of vagrant rsync-auto

var fs = require( "fs" ),
    recursiveread = require( "fs-readdir-recursive" ),
    marked = require( "marked" ),
    handlebars = require( "handlebars" ),
    gulp = require( "gulp" ),
    gulprun = require( "gulp-run" ),
    gulplock = require( "gulp-lock" ),
    gulpsmith = require( "gulpsmith" ),
    lunr = require( "metalsmith-lunr" ),
    layouts = require( "metalsmith-layouts" ),
    markdown = require( "metalsmith-markdown" ),
    metallic = require( "metalsmith-metallic" ),
    bower = require( "bower" ),
    rimraf = require( "rimraf" ),
    runsequence = require( "run-sequence" ),
    assign = require( "lodash.assign" ),
    gulpfrontmatter = require( "gulp-front-matter" );

handlebars.registerHelper( "whitespacetohyphens", function( input ) { return input.replace( / /g, "-" ) } );
handlebars.registerHelper( "stripsinglequotes", function( input ) { return input.replace( /'/g, "" ) } );

var out_dir = "dist/";

var paths = {
    libs: "bower_components/**",
    assets: "assets/**",
    metalsmith: "pages/**"
};

var sync_lock = gulplock();

gulp.task( "clean", function( callback )  {
    //rimraf( "node_modules", function {} ) // TODO: add node cleaning here, can't just delete!
    rimraf( "bower_components", function() {} );
    rimraf( "dist", callback );
});

gulp.task( "sync", sync_lock.cb( function( callback )  {
	credentials = fs.readFileSync( "./credentials.txt", "utf8" ).trim();
	lftp_options = "set ssl:verify-certificate false;";
	mirror_options = "mirror --reverse --delete --scan-all-first --loop --parallel=5 ./dist/ /;";
	command = new gulprun.Command( "lftp -u " + credentials + " sftp://192.168.60.240", { "verbosity": 0 } );
	command.exec( lftp_options + mirror_options, function() { callback; } );
}));

gulp.task( "bower", function( callback )  {
    bower.commands.install( [], { save: true }, {} ).on( "end", function( installed ) { callback(); });
});

gulp.task( "libs", function() { return gulp.src( paths.libs ).pipe( gulp.dest( out_dir + "libs/" ) ); });

gulp.task( "assets", function() { return gulp.src( paths.assets, { dot: true } ).pipe( gulp.dest( out_dir ) ); });

gulp.task( "metalsmith", function() {
    marked.setOptions({
        highlight: function ( code, lang ) { return require( "highlight.js" ).highlight( lang, code ).value; }
    });

    // FIXES: builtin partials support isn't great :(
    partials_location = "/pages/partials/";
    recursiveread( __dirname + partials_location ).forEach( function( filename ) {
        stripped_filename = filename.split(".").slice( 0, -1 ).join( "." );
        if ( stripped_filename != "" )  {
            handlebars.registerPartial( stripped_filename, fs.readFileSync( __dirname + partials_location + filename ).toString() );
        }
    });
    return gulp.src( paths.metalsmith.replace( "**", "content/**" ) )
        .pipe( gulpfrontmatter() ).on( "data", function( file ) {
            assign( file, file.frontMatter );
            delete file.frontMatter;
        })
        .pipe(
            gulpsmith()
                .use( lunr() )
                .use( markdown() )
                .use( metallic() )
                .use(
                	layouts({
                    	"engine": "handlebars",
                        "directory": "pages/templates/"
            		})
            	)
        )
        .pipe( gulp.dest( out_dir + "pages/" ));
});

gulp.task( "watch_libs", function( callback ) { gulp.watch( paths.libs, [ "libs" ], callback ) } );
gulp.task( "watch_metalsmith", function( callback ) { gulp.watch( paths.metalsmith, [ "metalsmith" ], callback ) } );
gulp.task( "watch_assets", function( callback ) { gulp.watch( paths.assets, [ "assets" ], callback ) } );
gulp.task( "watch", function( callback ) { runsequence( [ "watch_libs", "watch_metalsmith", "watch_assets" ] ); } );

gulp.task( "default", function( callback ) {
    runsequence(
		"clean",
		"bower",
		[ "libs", "assets", "metalsmith" ],
		"sync",
		callback
	)
} );
