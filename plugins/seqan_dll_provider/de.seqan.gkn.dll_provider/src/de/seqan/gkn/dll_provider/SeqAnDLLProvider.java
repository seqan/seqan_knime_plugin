package de.seqan.gkn.dll_provider;

import java.io.File;
import java.io.IOException;
import java.net.URL;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Enumeration;
import java.util.List;

import org.eclipse.core.runtime.FileLocator;
import org.osgi.framework.Bundle;
import org.osgi.framework.FrameworkUtil;

import com.genericworkflownodes.knime.custom.config.IDLLProvider;

public class SeqAnDLLProvider implements IDLLProvider {

	/**
	 * Path inside the bundle where the binaries should be located.
	 */
	public static final String BUNDLE_PATH = "payload";

	/**
	 * Path inside the bundle where the dlls should be located.
	 */
	private static final String DLLS_PATH = "/" + BUNDLE_PATH + File.separator + "lib";

	/**
	 * Default constructor.
	 */
	public SeqAnDLLProvider() {
	}

	@Override
	public List<File> getDLLs() {

		Bundle bundle = FrameworkUtil.getBundle(this.getClass());
		Enumeration<URL> urls = bundle.findEntries(DLLS_PATH, "*.dll", true);

		// findEntries returns null if no entry is found
		if (urls == null) {
			return Collections.emptyList();
		}

		List<File> dlls = new ArrayList<File>();

		// Get all urls.
		while (urls.hasMoreElements()) {
			File f = getFileFromUrl(urls.nextElement());
			dlls.add(f);
		}
		return dlls;
	}

	/**
	 * Get the bundle entry as {@link File} object.
	 *
	 * @param urlName The name of the url to get the File for.
	 * @return A File object pointing to the requested url or null if the file
	 *         wasn't found.
	 */
	private File getFileFromUrl(final URL urlName) {

		if (urlName == null) {
			return null;
		} else {
			try {
				// we found the requested file
				return new File(FileLocator.toFileURL(urlName).getFile());
			} catch (IOException ex) {
				return null;
			}
		}
	}
}
